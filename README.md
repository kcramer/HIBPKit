#  HIBPKit

[![CI](https://github.com/kcramer/HIBPKit/workflows/build/badge.svg)](https://github.com/kcramer/HIBPKit/actions?query=workflow%3Abuild)

HIBPKit is a Swift framework to query the [Have I Been Pwned?](https://haveibeenpwned.com/) database.

HIBPKit supports the v3 API.  In order to query breaches, you will need to acquire an [API key](https://haveibeenpwned.com/API/Key) and provide it when you initialize the service. 

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
