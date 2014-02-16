
# Ehon
[![Build Status](https://travis-ci.org/hekk/ehon.png?branch=master)](https://travis-ci.org/hekk/ehon)

Ehon is a simple `enum` library.

## Installation

Add this line to your application's Gemfile:

    gem 'ehon'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ehon

## Usage

You can create your enum class easily.

```ruby
class DeviceType
  include Ehon

  default user_agent_regexp: //

  UNKNOWN = enum 0, name: 'unknown'
  IOS     = enum 1, name: 'iOS',     user_agent_regexp: /(iPhone|iPad|iPod)/
  ANDROID = enum 2, name: 'Android', user_agent_regexp: /Android/
end
```

Using `DeviceType` class.

```ruby
DeviceType::IOS.id #=> 1
DeviceType::ANDROID.user_agent_regexp #=> /Android/
```

Finding.

```ruby
DeviceType[1, 2] #=> [#<DeviceType:...(iOS)>, #<DeviceType:...(Android)>]
DeviceType.find(name: 'iOS') #=> #<DeviceType:...(iOS)>
```

Custom method.

```ruby
class DeviceType
  %w[iOS Android unknown].each do |name|
    define_method :"#{name.downcase}?" do
      self.name == name
    end
  end
end
```

```ruby
DeviceTypel::IOS.ios? #=> true
DeviceTypel::IOS.android? #=> false
```

## Contributing

1. Fork it ( http://github.com/hekk/ehon/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

