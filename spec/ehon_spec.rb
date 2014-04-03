require 'spec_helper'

describe Ehon do
  it 'should have a version number' do
    expect(Ehon::VERSION).to_not be_nil
  end

  subject { Item }

  before :all do
    class Item
      include Ehon
    end
  end

  after do
    Item.contents = {}
    Item.default_options = {}
  end

  describe '.enum' do

    shared_examples_for 'a enum' do
      it 'should create one instance' do
        expect(subject.contents.size).to eq(1)
      end

      it 'instance id equals to argument' do
        expect(@instance.id).to eq(expected_id)
      end
    end

    context 'without options' do
      3.times do
        random_id = rand(10)

        before { @instance = subject.enum(expected_id) }

        context "id is #{random_id}" do
          let(:expected_id) { random_id }
          it_behaves_like "a enum"
        end
      end
    end

    context 'with options' do
      before { @instance = subject.enum(expected_id, expected_options) }

      let(:expected_id) { 3 }
      let(:expected_options) { {name: 'potion', value: 5} }

      it_behaves_like "a enum"

      it 'instance options equals to argument with id: 3' do
        expect(@instance.options).to eq(expected_options.merge(id: 3))
      end

      3.times do
        random_key   = ('a'..'z').to_a.shuffle.take(5).join.to_sym
        random_value = rand(100)

        context "with {#{random_key}: #{random_value}}" do
          let(:expected_options) { {random_key => random_value} }

          it "responds to #{random_key}" do
            expect(@instance).to be_respond_to(random_key)
          end

          it "instance should return #{random_value} when call #{random_key}" do
            expect(@instance.__send__(random_key)).to eq(random_value)
          end
        end
      end

      context 'with string key hash' do
        let(:name) { 'scroll' }

        before do
          @instance = subject.enum(1, 'name' => name)
        end

        it 'should not be able to respond to name' do
          expect(@instance).to_not be_respond_to(:name)
        end

        it 'should be able to fetch name through read_attribute' do
          expect(@instance.read_attribute('name')).to eq(name)
        end
      end
    end

    context 'with default options' do
      before do
        class Item
          default key: 'value'
        end
        @instance = subject.enum(1)
      end

      it "should has default option {key: 'value'}" do
        expect(subject.default_options).to eq({key: 'value'})
      end

      it "instacne should respond to key and return 'value'" do
        expect(@instance.key).to eq('value')
      end
    end

    context 'with block' do
      before do
        @instance_with_block = subject.enum(1, name: 'potion') {
          def potion?
            true
          end
        }
        @instance_without_block = subject.enum(2, name: 'pass')
      end

      it 'instance_with_block should respond to `potion?`' do
        expect(@instance_with_block).to be_respond_to(:potion?)
      end

      it 'instance_with_block should *not* respond to `potion?`' do
        expect(@instance_without_block).to_not be_respond_to(:potion?)
      end
    end

    context 'custom method' do
      before do
        class Item
          def name
            name  = read_attribute(:name)
            value = read_attribute(:value)
            "%s(%d)" % [name, value]
          end
        end
        @instance = subject.enum(1, name: 'potion', value: 5)
      end

      after do
        class Item
          remove_method :name
        end
      end

      it 'should override name attribute' do
        expect(@instance.name).to eq('potion(5)')
      end
    end
  end

  describe '#==(other)' do
    context 'same class' do
      before do
        @instance = Item.enum(1)
        @other    = @instance.dup
      end
      it 'instance should equal to cpy' do
        expect(@instance).to eq(@other)
      end
    end

    context 'same id but other class' do
      before do
        class Other
          include Ehon
        end
        @instance = Item.enum(1)
        @other    = Other.enum(1)
      end
      it "instance should not equal to other" do
        expect(@instance).to_not eq(@other)
      end
    end

    context 'with case' do
      before do
        class Difficulty
          include Ehon

          EASY   = enum 1, name: 'Easy mode'
          NORMAL = enum 2, name: 'Normal mode'
          HARD   = enum 3, name: 'Hard mode'
        end
        @selected = Difficulty::HARD
      end

      it 'selected mode should be hard' do
        should satisfy {
          case @selected
            when Difficulty::EASY   then false
            when Difficulty::NORMAL then false
            when Difficulty::HARD   then true
            else;                        false
          end
        }
      end
    end
  end

  describe '.all' do
    before do
      subject.enum 1
      subject.enum 2
      subject.enum 3
    end

    it 'should has 3 enums' do
      expect(subject.all.size).to eq(3)
    end

    # FIXME: it depends an implementation
    it 'all should return contents.values' do
      expect(subject.all).to eq(subject.contents.values)
    end
  end

  describe '.find(id_or_query)' do
    before do
      subject.enum 1,   name: 'potion',      value: 5
      subject.enum 2,   name: 'high potion', value: 10
      subject.enum '3', name: 'scroll'
      subject.enum 4,   name: 'stone',       value: 5
    end

    context 'with key' do
      it 'find with id 1 should return potion' do
        finded = subject.find(1)
        expect(finded.name).to eq('potion')
      end

      it "find with id '3' should return scroll" do
        finded = subject.find('3')
        expect(finded.name).to eq('scroll')
      end

      it 'find with id 12 should return nil' do
        finded = subject.find(12)
        expect(finded).to be_nil
      end
    end

    context 'with multiple id' do
      it 'find with id 1 and 2 should return `potion` and `high potion`' do
        finded = subject.find(1, 2)
        expect(finded.map(&:name)).to eq(['potion', 'high potion'])
      end

      it 'find with id 1 and 9 should return `potion` only but array' do
        finded = subject.find(1, 9)
        expect(finded.map(&:name)).to eq(['potion'])
      end

      it 'find with id [1, 2] should return `potion` only but array' do
        finded = subject.find([1, 2])
        expect(finded.map(&:name)).to eq(['potion', 'high potion'])
      end

      it 'find with id [5, 8] should return empty array' do
        finded = subject.find([5, 8])
        expect(finded).to eq([])
      end
    end

    context 'with query' do
      it "find with `{name: 'high potion'}` should return item id 2" do
        finded = subject.find(name: 'high potion')
        expect(finded.id).to eq(2)
      end

      it "find with `{value: 10}` should return item id 1" do
        finded = subject.find(value: 10)
        expect(finded.id).to eq(2)
      end

      it "find with `{id: '3'}` should return item id '3'" do
        finded = subject.find(id: '3')
        expect(finded.id).to eq('3')
      end

      it "find with `{name: 'food'}` should return nil" do
        finded = subject.find(name: 'food')
        expect(finded).to be_nil
      end

      it 'find with `{value: 5}` should return 2 items' do
        finded = subject.find(value: 5)
        expect(finded.size).to eq(2)
      end

      context 'AND search' do
        it "find with `{name: 'potion', value: 5}` should return item id 1" do
          finded = subject.find(name: 'potion', value: 5)
          expect(finded.id).to eq(1)
        end

        it "find with `{name: 'potion', value: 10}` should return nil" do
          finded = subject.find(name: 'potion', value: 10)
          expect(finded).to be_nil
        end
      end

      context 'OR search' do
        it "find with `[{name: 'potion'}, {value: 10}]` should return item id `potion` and `high potion`" do
          finded = subject.find([{name: 'potion'}, {value: 10}])
          expect(finded.map(&:name)).to eq(['potion', 'high potion'])
        end

        it "find with `{name: 'potion', value: 20}` should return potion only but array" do
          finded = subject.find([{name: 'potion'}, {value: 20}])
          expect(finded.map(&:name)).to eq(['potion'])
        end

        it "find with `{name: 'fire potion', value: 20}` should return empty array" do
          finded = subject.find([{name: 'fire potion'}, {value: 20}])
          expect(finded).to eq([])
        end
      end
    end

    context 'with id and query' do
      it "find with `[1, {value: 10}]` should return item id `potion` and `high potion`" do
        finded = subject.find([1, {value: 10}])
        expect(finded.map(&:name)).to eq(['potion', 'high potion'])
      end
    end
  end

  describe '.create_xxxs!' do
    before do
      Item.enum 1, name: 'test'
    end

    after do
      subject.class_eval do
        remove_method :name  rescue nil
        remove_method :name= rescue nil
      end
    end

    context 'create both' do
      before do
        subject.create_accessors!
      end

      it 'has id attribute reader' do
        item = subject.find(1)
        expect(item.id).to eq(1)
      end

      it 'does not have id attribute writer' do
        expect { subject.public_instance_method(:id=) }.to raise_error
      end

      it 'has name attribute reader' do
        expect { subject.public_instance_method(:name) }.not_to raise_error
        item = subject.find(1)
        expect(item.name).to eq('test')
      end

      it 'has name= attribute writer' do
        expect { subject.public_instance_method(:name=) }.not_to raise_error
        expect_name = 'cat'
        item = subject.find(1)
        item.name = expect_name
        expect(item.name).to eq(expect_name)
      end
    end

    context 'create only reader' do
      before do
        subject.create_readers!
      end

      it 'has name attribute readers' do
        expect{ subject.public_instance_method(:name) }.not_to raise_error
      end

      it 'does not have name= attribute writer' do
        expect { subject.public_instance_method(:name=) }.to raise_error
      end
    end

    context 'create only writers' do
      before do
        subject.create_writers!
      end

      it 'does not have name attribute reader' do
        expect{ subject.public_instance_method(:name) }.to raise_error
      end

      it 'has name= attribute writer' do
        expect { subject.public_instance_method(:name=) }.not_to raise_error
      end
    end

    context 'duplicate define' do
      before do
        subject.create_accessors!
      end

      it 'does nothing' do
        expect { subject.create_accessors! }.to_not raise_error
      end
    end
  end
end
