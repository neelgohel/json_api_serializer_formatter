# JSON API Serializer Formatter

Currently,for data serialization in APIs rails is using `active_model_serializers` by default.
But, 'jsonapi-serializer[https://github.com/jsonapi-serializer/jsonapi-serializer]' is one of the better options. If we switch to the jsonapi option the response for the APIs will be differ as compare to the activemodel serializer's response.

Now, migrating to the jsonapi serializer can bew difficult for the application which are already using the activemodel serialzer.As we might also need to change the frontend code in order to take advantage of the jsonapi serializer.

So, I added a new mokeypatch method in the jsonapi serilizer which converts the reponse of the serialization mehtod as per the activemodel serializer. Using this monkeypatch we dont have to change the frontend code. With this monkey patch method the api reponse will be identical for both the serializers.

The monkeypatched method can be found [here](config/initializers/json_api_serializer_formatter.rb).

To use this in you rails application you have to add the following gem to the Gemfile and also need to add [this file](config/initializers/json_api_serializer_formatter.rb) to your `config/initializers` folder.

  ```
  gem 'jsonapi-serializer'
  ```

## Benchmark

You can also run the benchamrk results by running [this file(benchmark_data.rb)] in rails console.

For 1000 Records,

================================
ActiveModel Serializer Benchmark      
  0.134760   0.000093   0.134853 (  0.137027)
================================      

================================      
JSONApi Serializer Benchmark          
  0.022771   0.000041   0.022812 (  0.022845)
================================
