#**Zendesk Ruby Wrapper**

I made this wrapper as a result of needing an easy, flexible way to access and manipulate Zendesk's Help Center API. The end result is that this wrapper can GET, POST, PUT, and DELETE to any of Zendesk's endpoints, and provides a few flexible options for doing so and being used in custom scripts.

##Revisions
0.1.0 -> Basic functionality, the wrapper is able to GET, POST, PUT and DELETE to any of the Zendesk API endpoints.

##Configuring the wrapper
The wrapper requires custom configuration constants be added to `scripts/config/zd_api_vars.rb`:

```ruby
# Constants for when acessing the production Zendesk
ZENDESK_EMAIL = "your_lumos_email@lumoslabs.com"
ZENDESK_API_TOKEN = "yourProductionZendeskAPIToken"
ZENDESK_API_URL 	 = "https://help.lumosity.com/api/v2"

# Constants for when accessing the sandbox Zendesk
SANDBOX_EMAIL = "your_lumos_email@lumoslabs.com"
SANDBOX_API_TOKEN = "yourSandboxZendeskAPIToken"
SANDBOX_API_URL 	 = "https://lumosity1375404535.zendesk.com/api/v2"
```

**Note:** This file contains sensitive information and should never be included in the repo. By default, when you clone the repo, you will find `zd_api_vars_example.rb` in `scripts/config`, which you can then rename to `zd_api_vars.rb` and insert your information. The .gitignore file for that directory is set to never track `zd_api_vars.rb`.

##Using the wrapper
To use the wrapper, first include it in your script with
`require_relative '../relative/path/to/zd_http'`.

The entire wrapper consists of a single class: `ZDHttpAPI`, which then has GET, POST, PUT and DELETE methods.

To beging using the wrapper, create an instance of `ZDHttpAPI` with either the `:sandbox` or `:production` argument, depending on which Zendesk instance you want to access.

**Example:**
```ruby
require_relative '../config/zd_http'

production = ZDHttpAPI.new(:production)
sandbox = ZDHttpAPI.new(:sandbox)
```

You can now use the following methods to access the Zendesk API:

### get(endpoint, opt={}) → hash or array
Peforms a GET request at the specified *endpoint*. If the response is only a single item (e.g., a user), then it will be returned as a hash. Otherwise, the result wiill be an array populated with hashes. The hash keys are returned as :symbols and correspond to the response structure in the Zendesk API documentation (https://developer.zendesk.com/rest_api/docs/)

The endpoint argument must include the leading slash, e.g. `/macros.json`. Options are passed as a hash in the second argument, and can have the following keys:

* **:verbose |** Outputs the response code, message, and body, as well as some information about the request the script is performing. Default is `false`.


* **:long_uri |** Overrides the concatenation of the configured ZD_URL or SB_URL path with the `endpoint` argument, and instead uses the `endpoint` argument by itself as the request URI. This is useful when you are dealing with pagination manually, or using sideloading URLs from the ZD response. This argument is mostly used by the wrapper automatically for pagination. Default is `false`.

**Example:**
```ruby
production = ZDHttpAPI.new(:production)
production.get("/users/me.json") #=> {:id => "68197665", :name => "User1", (...)}
```

### post(endpoint, json_payload, opt={}) → hash
Performs a POST request at the specified *endpoint*. The method will then return the response from Zendesk for the newly created object as a hash, which you can then use and manipulate if assigned to a variable. The *json_payload* **MUST** be properly formatted according to Zendesk's API documentation, otherwise it will return a 422 Unprocessable Entity. 

There is no implicit conversion of the input to JSON, the source must already be properly formatted and a JSON object. Since `zd_http.rb` requires the JSON library, it is automatically included in any scripts using the wrapper. To convert a Ruby hash to JSON, simply append the `#to_json` method to it or use [JSON#generate](http://ruby-doc.org/stdlib-2.0/libdoc/json/rdoc/JSON.html#method-i-generate).

**Note:** Some endpoints in Zendesk's API may be buggy or will not POST correctly if the payload is not properly formatted. Usually the response body is indicative of what exactly Zendesk is expecting but not receiving. In general, it is a good idea to use verbose mode with `#post`.

The endpoint argument must include the leading slash, e.g. `/macros.json`. Options are passed as a hash in the third argument, and can have the following keys:

* **:verbose |** Outputs the response code, message, and body, as well as some information about the request the script is performing. Default is false.

**Example:**
```ruby
sandbox = ZDHttpAPI.new(:sandbox)

payload = {
	category => {
      :name 	   => "New category",
      :description => "This is a new category"
      }
    }.to_json

new_cat = sandbox.post("/help_center/categories.json", payload) #=> {:id => "1234567", :name "New category", (...)}
new_cat[:id] #=> 1234567
```

### put(endpoint, json_payload, opt={}) → hash
Performs a PUT request at the specified *endpoint*. The method will then return the response from Zendesk for the newly created object as a hash, which you can then use and manipulate if assigned to a variable. The *json_payload* **MUST** be properly formatted according to Zendesk's API documentation, otherwise it will return a 422 Unprocessable Entity.

There is no implicit conversion of the input to JSON, the source must already be properly formatted and a JSON object. Since `zd_http.rb` requires the JSON library, it is automatically included in any scripts using the wrapper. To convert a Ruby hash to JSON, simply append the `#to_json` method to it or use [JSON#generate](http://ruby-doc.org/stdlib-2.0/libdoc/json/rdoc/JSON.html#method-i-generate).

**Note:** Zendesk does not support updating all properties of all entries via PUT requests, often limiting what data can be updated to a few select properties. Please refer to the Zendesk API documentation to see what properties can be updated at which endpoints.

The endpoint argument must include the leading slash, e.g. `/macros.json`. Options are passed as a hash in the third argument, and can have the following keys:

* **:verbose |** Outputs the response code, message, and body, as well as some information about the request the script is performing. Default is false.

**Example:**
```ruby
sandbox = ZDHttpAPI.new(:sandbox)

payload = {
	category => {
      :name 	   => "Updated category",
      :description => "This is an updated category"
      }
    }.to_json

upd_cat = sandbox.put("/help_center/categories/1234567.json", payload) #=> {:id => "1234567", :name "Updated category", (...)}
upd_cat[:id] #=> 1234567
```

### delete(endpoint, opt={}) → nil
Performs a DELETE request at the specified *endpoint*. The method will not return any response as a result of its action, but will output the 200 OK response code (when successful) if `:verbose` is set to true.

**Note:** The DELETE method, by default, has a built-in safety feature that requires confirming that you intend to delete something. This was implemented to prevent accidental deletions, which are, insofar as I understand, irreversible in Zendesk. Please see the `:override_warning` option below, and use with caution.

The endpoint argument must include the leading slash, e.g. `/macros.json`. Options are passed as a hash in the second argument, and can have the following keys:

* **:verbose |** Outputs the response code and message, as well as some information about the request the script is performing. Default is false.

* **:override_warning |** Overrides the built-in deletion warning and confirmation entirely. When this option is set to `true`, there will be no warning, and any script using this method will automatically do any and all deletions (quickly, at that). It is recommended that this option be used cautiously and only if you're 100% positive what your script is deleting is what you intend it to delete. This method will ***not*** capture or account for ***any*** errors in logic.

**Example**

```ruby
sandbox = ZDHttpAPI.new(:sandbox)

sandbox.delete("/help_center/categories/1234567.json", {:override_warning => true, :verbose => true}) #=> NilClass

#=> STDOUT = "Response: 200 OK"

```

##Shortcomings / Future Revisions

Currently, the warapper does not include any sort of error handling. If you unsuccesfully submit a request and and get a 404 or other HTML response from Zendesk, it will simply return a `JSON::ParseError`. An invalid URI will return a `NoMethodError`, etc. Future revisions will include better error handling.

I have not tested the wrapper with every single Zendesk endpoint, so it's possible some odd endpoints with oddball response structures might not work as intended. It's always recommended that you test endpoint responses before deciding a script is functional. If you find any endpoints where a response is problematic or improperly/unexpectedly formatted, please submit an issue!

I would like to, in the future, create a command line tool that allows you to test requests in a simple manner, based around the wrapper. That would likely be a separate project that uses the wrapper as its main components.