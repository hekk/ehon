
# Ehon
[![Build Status](https://travis-ci.org/hekk/ehon.png?branch=master)](https://travis-ci.org/hekk/ehon)
[![Code Climate](https://codeclimate.com/github/hekk/ehon.png)](https://codeclimate.com/github/hekk/ehon)
[![Gem Version](https://badge.fury.io/rb/ehon.png)](http://badge.fury.io/rb/ehon)

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

### Finding.

You can find your item from enum class with following 2 way.

```ruby
DeviceType[1, 2] #=> [#<DeviceType:...(iOS)>, #<DeviceType:...(Android)>]
DeviceType.find(name: 'iOS') #=> #<DeviceType:...(iOS)>
```

and you also list all items using `#all` method

```ruby
DeviceType.all #=> [iOS, Android, unknown]
```

### Custom methods.

You can define any method for your enum class.

```ruby
class DeviceType
  def ios?
    self.name == "iOS"
  end

  def android?
    self.name == "Android"
  end

  def unknown?
    self.name == "unknown"
  end

  def valid_user_agent?(user_agent)
    !!(self.user_agent_regexp =~ user_agent)
  end
end
```

```ruby
DeviceType::IOS.ios? #=> true
DeviceType::IOS.android? #=> false

user_agent = 'Mozilla/5.0 (Linux; Android 4.4.4; KYV33 Build/xxxx)'
DeviceType::ANDROID.valid_user_agent?(user_agent) #=> true
```

## Contributing

1. Fork it ( http://github.com/hekk/ehon/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

