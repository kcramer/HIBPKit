#  HIBPKit

[![CI Status](https://img.shields.io/travis/com/kcramer/HIBPKit.svg?style=flat)](https://travis-ci.com/kcramer/HIBPKit)

HIBPKit is a Swift framework to query the [Have I Been Pwned?](https://haveibeenpwned.com/) database.

It supports these queries:

* Check if a password was found in a breach.
* Check if an account name or email was found in a breach.
* Check if an email was found in a paste.

The query is performed asynchronously (on a dispatch queue from the URLSession) and the 
results are returned via a callback.  The callback is run on the dispatch queue from the 
URLSessionTask, so switch to the main queue or another queue as appropriate.

By default the fetching of the data is performed with an URLSession but it can be overridden 
to obtain the data by another method or for testing purposes.

```Swift
let service = HIBPService(userAgent: "My-User-Agent")
service.passwordByRange(password: "passwordtocheck") { result in
    switch result {
    case .success(let count):
        DispatchQueue.main.async {
            // Update the UI with the result.
            countLabel.text = "\(count)"
        }
    case .failure(let error):
        // Handle the error
}
```
