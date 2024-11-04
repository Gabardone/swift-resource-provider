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
the same type. Either way we have a builder method as follows:

```swift
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

func makeImageProvider() -> ThrowingAsyncProvider<URL, CGImage> {
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
            .mapValue { data, _ in
                data
            } fromStorage: { data in
                data.flatMap { data in UIImage(data: data).map { (data, $0) } }
            }
        )
        .mapValue { _, image in
            image
        }
        .cache(WeakObjectCache())
        .coordinated() // Finish an `async` provider chain with this to avoid accidentally doing work twice for same ID.
}
```

Let's look at all of this step by step…

```swift
ResourceProvider.networkDataSource()
```

Every provider needs a source, which is expected to always return a thing. If it can't, it ought to `throw`. If you are
reasonably sure it will never fail (i.e. if you are generating the values in code based on some parameters so all the
logic happens under your control) then you can use a non-throwing `Provider` type and simplify its use at the call site.

In this case we are using the simple `Provider.networkDataSource()` method that just returns a source that downloads the
data from the given `URL`, used as its `ID`, and fails (throws) if the download operation fails for any reason.

```swift
.mapValue { data in
    guard let image = UIImage(data: data) else {
        throw ImageConversionError()
    }

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
    .mapValue { data, _ in
        data
    } fromStorage: { data, _ in
        UIImage(data: data).map { (data, $0) }
    }
)
```

We would like to store these images in local files, in a cache folder that the system can delete if it needs more space.
Luckily for us `LocalFileDataCache` does just that.

However, `LocalFileDataCache` runs on `FilePath` and `Data` since it needs things it can easily write to and read from
the file system. `mapID` will convert our URLs into something that the file system likes —the sample code assumes that
the last path component will be unique enough— and `mapValue` will strip out the `UIImage` on the way to cache storage
and recreate it if needed.

Note that a failure to create a `UIImage` would not be a hard failure since it can still go check for the network data
again. We can just return `nil` and in real logic we would also be logging an error so we can notice the issue.

Finally, both mapping methods take in the requested `id`, which we don't need in this case but can often help either
encode information contained in the `id` and/or rebuild the original values based on the `id` they represent.

```swift
.mapValue { _, image in
    image
}
```

We're done with wrangling raw `Data` from now on, so we just filter it out and pass down the `UIImage`.

```swift
.cache(WeakObjectCache())
```

A weak objects cache means we'll have instant access to any object that someone else has fetched before and is already
using, so it's mostly "free". Other in-memory alternatives can be built with whatever cache invalidation approaches may
work best. `NSCache` sounds good but is rarely what you actually want.

```swift
.coordinated()
```

You will always want to finish any `async` cache chain with this one. It guarantees that whatever other work has to
happen deeper (above) will not be repeated if any other part of your app requests the same item while it's being worked
on.

## But Wait, One More Example

Ok now you're loading those images but dropping them full size on your UI is making your app performance sad. So you go
to your friendly neighborhood backend engineer:

"Could we add thumbnail URLs to the API"

"No"

Your backend friends are too busy working on the CEOs latest flight of fancy: Uber, but for playing D&D. You're gonna
have to do something about this yourself. Well here comes `ResourceProvider` to save the day again…:

```swift
func makeThumbnailProvider() -> ThrowingAsyncProvider<URL, UIImage> {
    makeImageProvider()
        .mapValue { image in
            if image.isLargerThanThumbnail {
                image.downscaled(size: thumbnailSize)
            } else {
                return image
            }
        }
        .cache(WeakObjectCache())
        .coordinated()
}
```

This should help. And if it doesn't help _enough_, you can build up something more sophisticated the same way. Your
provider could literally return a publisher that returns the large image first and the thumbnail once calculated or a
different caching policy may work better for this use case.

## Tips & Tricks

- `ResourceProvider` doesn't make complexity go away, but it helps manage it. You're still going to have to think things
through and be careful with your provider design.
- Start with the dumbest setup you can get away with and increase the complexity of individual components as performance
measurements indicate it will be the most impactful.
- When implementing providers or caches, if reentrancy may be an issue an `actor` is your best friend. In the context of
solving the problems that `ResourceProvider` is meant to help with, order of execution of concurrent tasks is almost
never one, which makes `actors` a perfect fit for shielding against reentrancy issues. And remember that the basic
avoidance of repeated work for the same ID is already taken care of by `coordinated()`.
- Bears repeating: always finish off an `AsyncProvider` or `ThrowingAsyncProvider` with `coordinated()`
- The given components (`Provider.networkDataSource`, `LocalFileDataCache` etc.) are purposefully the dumbest
implementations that work. Feel free to copy/paste them and use more sophisticated logic if your use case warrants it.
