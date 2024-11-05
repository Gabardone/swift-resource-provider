# swift-resource-provider

A modular resource fetching and management system.

This little library takes a Combine-like approach to getting things with an identifier. It makes for an easy to
understand surface for this common abstraction of getting something repeatably based on a series of unique
characteristics while enabling for progressively adding sophistication to the implementation in composable steps,
including but not limited to caching steps.

As with many similar frameworks and language facilities, this doesn't make these complicated issues simple but it ought
to help organize them in a far more modular and testable way.

You can find the full module API documentation at the [Swift Package Index documentation archive](https://swiftpackageindex.com/Gabardone/swift-resource-provider/documentation)

## Example

Suppose you are working on your CRUD app and find yourself in the following scenario, which no one has encountered
before:

- Your API is returning URLs for your data's images.
- Those images are sizable and take a bit to download.
- The image URLs are stable:
  - URL uniquely identifies an image.
  - Image pointed at by a given URL will not change.
- Download may fail because network or because backend or because “software amirite”.
- You want to display the UI already and update the images when they arrive.

We are also assuming that the image type is either packaged in the ID type used through the app or that they are all
the same type. We can summarize both with the following declarations:

```swift
struct ImageID: Hashable {
    var id: <some type>
    
    var url: URL
    
    var type: UTType
}

extension CGImage {
    static func make(from data: Data, with id: ID) throws -> CGImage { … }
}
``` 

This library won't help you with displaying _good_ UI while you wait for image downloads. You better convince your
backend workmates to send in some media metadata like the image size. But as for a reasonably efficient fetch and cache
system for the images you could be writing something like _this_:

```swift
import ResourceProvider

// Papering over the specifics of error reporting for this example.
struct ImageConversionError: Error {}

func makeImageProvider() -> some AsyncProvider<ImageID, CGImage, any Error> {
    Provider.networkDataSource()
        .mapID(\.url)
        .mapValue { data, id in
            let image = try CGImage.make(from: data, with: id)
            return (data, image)
        }
        .cache(LocalFileDataCache()
            .mapID { url in
                FilePath(url.lastPathComponent)
            }
            .mapValueToStorage { data, _ in
                data
            } fromStorage: { data, id in
                data.flatMap { data in try? CGImage.make(from: data, with: id).map { (data, $0) } }
            }
            .concurrent()
        )
        .mapValue { _, image in
            image
        }
        .cache(WeakObjectCache()
            .forceSendable()
            .serialized()
        )
        .coordinated()
}
```

Let's look at all of this step by step…

```swift
Provider.networkDataSource()
```

Every provider needs a source, which is expected to always return a thing or `throw` If it can't. If you're luckily in
control of the source's logic such that you are reasonably sure it will never fail you can pass in a source that does
not `throw` and whatever operators you apply to it won't need to deal with `try` and `catch`.

In this case we are using the simple pre-built `Provider.networkDataSource()` method that just returns a source that
downloads the data from the given `URL`, used as its `ID`, and fails (throws) if the download operation fails for any
reason.

```swift
.mapID(\.url)
```

Our IDs don't have to be simple strings or UUIDs, they can be anything we want as long as they are `Hashable`. So in
many cases we will be using a `struct` including whatever metadata we need to encode and decode the resource into
agnostic storage.

In this example we are packaging up both the `URL` and the `UTType` of our resource, the latter of which comes in handy
for decoding a `CGImage` from `Data`. Prebuilt `networkDataSource` however only takes `URL` so we extract it from our
`id`.

```swift
.mapValue { data, id in
    let image = try CGImage.make(from: data, with: id)
    return (data, image)
}
```

We don't want to cache the `Data` we got from the network if it turns out it's no good for our display needs. That would
also lock in an immediate failure on subsequent attempts, where it may not be the expectation (i.e. the data we got the
first time was corrupted). So it's usually wiser to validate before we start caching.

To retry, just request the item again after it has failed.

We pass down both the data and the generated image so we don't have to re-process it on its way back to the caller.

```swift
.cache(LocalFileDataCache()
    .mapID { url in
        FilePath(url.lastPathComponent)
    }
    .mapValueToStorage { data, _ in
        data
    } fromStorage: { data, id in
        data.flatMap { data in try? CGImage.make(from: data, with: id).map { (data, $0) } }
    }
)
```

We would like to store these images in local files, in a cache folder that the system can delete if it needs more space.
Luckily for us `LocalFileDataCache` does just that.

However, `LocalFileDataCache` runs on `FilePath` and `Data` since it needs things it can easily write to and read from
the file system. `mapID` will convert our URLs into something that the file system likes —the sample code assumes that
the last path component will be unique enough— and `mapValueToStorage(_:fromStorage)` will strip out the `UIImage` on
the way to cache storage and recreate it on the way back when needed.

Note that a failure to create a `UIImage` would not be a hard failure since it can still go check for the network data
again. We can just return `nil` and in real world logic we would also be logging an error and/or doing an assertion so
we can notice if that ever happens.

Note that both mapping methods take in the requested `id`, which we don't need for storage in this case but comes in
handy on the way back from storage as our provider id has type information embedded within.

Finally, since `LocalFileDataCache` is `Sendable` and is friendly with concurrent use as long as the same file isn't
modified concurrently —an issue with which we're dealing with later—. We apply `concurrent()` to it so it can be…
concurrently used by the rest of the provider.

```swift
.mapValue { _, image in
    image
}
```

We're done with wrangling raw `Data` from now on, so we just filter it out and pass down the `UIImage`.

```swift
.cache(WeakObjectCache()
    .forceSendable()
    .serialized()
)
```

A weak objects cache means we'll have instant access to any object that someone else has fetched before and is already
using, so it's mostly "free". Other in-memory alternatives can be built with whatever cache invalidation approaches may
work best. `NSCache` sounds good but is rarely what you actually want.

Because it's built using old, non-concurrency-friendly Foundation types, `WeakObjectCache` is not `Sendable`, trying to
use it concurrently would cause data races. But because it just performs a dictionary lookout we can wrap it in an
`actor` which guarantees its serial use without introducing real world performance issues. First we must use
`forceSendable` in an "I know what I'm doing" way, then apply `.serialized()` to it.

```swift
.coordinated()
```

You will always want to finish off any `async` provider with this one. It guarantees that whatever other work has to
happen deeper in, further up in the code, will not be repeated if any other part of your app requests the same item
while it's being worked on.

Once you got this thing back, you will want a discrete type to store the results. Use `AnyAsyncProvider` for that, which
also makes it easier to replace this whole thing with a mock for testing purposes.

## But Wait, One More Example

Ok now you're loading those images but dropping them full size on your UI is making your app performance sad. So you go
to your friendly neighborhood backend engineer:

"Could we add thumbnail URLs to the API"

"No"

Your backend friends are too busy working on the CEOs latest flight of fancy: Uber, but for playing D&D. You're gonna
have to do something about this yourself. Well, we already have an image provider. Yo dawg, how about we make a
thumbnail provider off the image provider?

Like this:

```swift
struct ThumbnailID: Hashable {
    var image: ImageID
    
    var size: CGSize
}

func makeThumbnailProvider() -> some AsyncProvider<ThumbnailID, CGImage, any Error> {
    makeImageProvider()
        .mapID(\.image)
        .mapValue { image, id in
            if image.isLargerThanSize(id.size) {
                image.downscaled(size: id.size)
            } else {
                return image
            }
        }
        .cache(WeakObjectCache()
            .forceSendable()
            .serialized()
        )
        .coordinated()
}
```

We'll leave the step-by-step decomposition of this one to the reader.

This should help. And if it doesn't help _enough_, you can build up something more sophisticated using the tools offered
by this package and some ingenuity.

You are also not obligated to return data types directly from providers. You could return `Task`, or publishers (careful
as the Combine ones are not `Sendable` so far) or something else that has the desired behavior the rest of your app
craves.

## Tips & Tricks

### General

- `swift-resource-provider` doesn't make complexity go away, but it helps manage it. You're still going to have to think
things through and be careful with your provider design.
- Start with the dumbest setup you can get away with and increase the complexity of individual components as performance
measurements indicate where the bottlenecks are.
- The given components (`Provider.networkDataSource`, `LocalFileDataCache` etc.) are purposefully the dumbest
implementations that work. Feel free to copy/paste them and grow them with more sophisticated logic if your use case
warrants it.

### Dealing with concurrency

- When implementing providers or caches, if reentrancy may be an issue an `actor` is your best friend. In the context of
solving the problems that `swift-resource-provider` is meant to help with, order of execution of concurrent tasks is
almost never one, which makes `actors` a perfect fit for shielding against reentrancy issues. And remember that the
basic avoidance of repeated work for the same ID is already taken care of by `coordinated()`.
- That said, don't run declare your own actors when you have `.serialized()`, `.concurrent()` and `.coordinated()` to
play with. Do so only if you need custom behaviors that those operators won't solve.
- Keep things sync as much as you can and make them async as late as you can. Think through the consequences of running
a sync provider or cache in an async environment and document the results. Normally but not always sticking to.
- Just because a cache or provider is dealing with `Sendable` types doesn't mean that it works fine in a concurrent
environment.
- Bears repeating: always finish off an `AsyncProvider` with `coordinated()`
