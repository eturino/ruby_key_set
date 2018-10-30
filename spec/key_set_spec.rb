# frozen_string_literal: true

require 'spec_helper'

# rubocop:disable Style/CaseEquality
RSpec.describe KeySet do
  let(:key_set_all_except_some) { described_class.all_except_some all_except_some_keys }
  let(:key_set_some) { described_class.some some_keys }
  let(:key_set_none) { described_class.none }
  let(:key_set_all) { described_class.all }
  let(:all_except_some_keys) { [key2, key4, key4].sort.reverse }
  let(:some_keys) { [key1, key3, key3].sort.reverse }
  let(:key5) { 'key5' }
  let(:key4) { 'key4' }
  let(:key3) { 'key3' }
  let(:key2) { 'key2' }
  let(:key1) { 'key1' }

  it 'has a version number' do
    expect(KeySet::VERSION).not_to be nil
  end

  describe 'do not use it directly (KeySet.new)' do
    it { expect { described_class.new }.to raise_error(NoMethodError) }
  end

  describe '.all' do
    context 'returns a KeySet representing all keys' do
      it { expect(key_set_all).to be_a KeySet::All }
      it { expect(key_set_all).to be_represents_all }
      it { expect(key_set_all).not_to be_represents_none }
      it { expect(key_set_all).not_to respond_to :keys }
    end
  end

  describe '.none' do
    context 'returns a KeySet representing none of they' do
      it { expect(key_set_none).to be_a KeySet::None }
      it { expect(key_set_none).not_to be_represents_all }
      it { expect(key_set_none).to be_represents_none }
      it { expect(key_set_none).not_to respond_to :keys }
    end
  end

  describe '.some' do
    context 'returns a KeySet representing none of they' do
      it { expect(key_set_some).to be_a KeySet::Some }
      it { expect(key_set_some).not_to be_represents_all }
      it { expect(key_set_some).not_to be_represents_none }
      it { expect(key_set_some).to respond_to :keys }

      it '#keys accesses the keys sorted, without duplicates' do
        expect(key_set_some.keys.to_a).to eq some_keys.to_a.uniq.sort
      end
    end
  end

  describe '.all_except_some' do
    context 'returns a KeySet representing none of they' do
      it { expect(key_set_all_except_some).to be_a KeySet::AllExceptSome }
      it { expect(key_set_all_except_some).not_to be_represents_all }
      it { expect(key_set_all_except_some).not_to be_represents_none }
      it { expect(key_set_all_except_some).to respond_to :keys }

      it '#keys accesses the keys sorted, without duplicates' do
        expect(key_set_all_except_some.keys.to_a).to eq all_except_some_keys.to_a.uniq.sort
      end
    end
  end

  describe '#remove' do
    context 'All' do
      subject(:key_set) { described_class.all }

      context 'KeySet.all.remove(KeySet.all)' do
        let(:result) { key_set.remove(described_class.all) }

        it 'we have everything, we remove everything => we have nothing' do
          expect(result).to be_a KeySet::None
          expect(result.object_id).not_to eq key_set.object_id
        end
      end

      context 'KeySet.all.remove(KeySet.none)' do
        let(:result) { key_set.remove(described_class.none) }

        it 'we have everything, we remove nothing => we have everything' do
          expect(result).to be_a KeySet::All
          expect(result.object_id).not_to eq key_set.object_id
        end
      end

      context 'KeySet.all.remove(KeySet.some [key1, key2])' do
        let(:result) { key_set.remove(described_class.some([key1, key2])) }

        it 'we have everything, we remove some => we have all except those' do
          expect(result).to be_a KeySet::AllExceptSome
          expect(result.keys.to_a).to eq [key1, key2]
          expect(result.object_id).not_to eq key_set.object_id
        end
      end

      context 'KeySet.all.remove(KeySet.all_except_some [key1, key2])' do
        let(:result) { key_set.remove(described_class.all_except_some([key1, key2])) }

        it 'we have everything, we remove all except some => we have only those' do
          expect(result).to be_a KeySet::Some
          expect(result.keys.to_a).to eq [key1, key2]
          expect(result.object_id).not_to eq key_set.object_id
        end
      end

      context 'KeySet.all.remove([key1, key2])' do
        it do
          expect { key_set.remove([key1, key2]) }.to raise_error(ArgumentError)
        end
      end
    end

    context 'None' do
      subject(:key_set) { described_class.none }

      context 'KeySet.none.remove(KeySet.all)' do
        let(:result) { key_set.remove(described_class.all) }

        it 'we have nothing, we remove everything => we have nothing' do
          expect(result).to be_a KeySet::None
          expect(result.object_id).not_to eq key_set.object_id
        end
      end

      context 'KeySet.none.remove(KeySet.none)' do
        let(:result) { key_set.remove(described_class.none) }

        it 'we have nothing, we remove nothing => we have nothing' do
          expect(result).to be_a KeySet::None
          expect(result.object_id).not_to eq key_set.object_id
        end
      end

      context 'KeySet.none.remove(KeySet.some [key1, key2])' do
        let(:result) { key_set.remove(described_class.some([key1, key2])) }

        it 'we have nothing, we remove some => we have nothing' do
          expect(result).to be_a KeySet::None
          expect(result.object_id).not_to eq key_set.object_id
        end
      end

      context 'KeySet.none.remove(KeySet.all_except_some [key1, key2])' do
        let(:result) { key_set.remove(described_class.all_except_some([key1, key2])) }

        it 'we have nothing, we remove all except some => we have nothing' do
          expect(result).to be_a KeySet::None
          expect(result.object_id).not_to eq key_set.object_id
        end
      end

      context 'KeySet.none.remove([key1, key2])' do
        it do
          expect { key_set.remove([key1, key2]) }.to raise_error(ArgumentError)
        end
      end
    end

    context 'Some' do
      subject(:key_set) { described_class.some([key1, key3]) }

      context 'KeySet.some([key1, key3]).remove(KeySet.all)' do
        let(:result) { key_set.remove(described_class.all) }

        it 'we have some, we remove everything => we have nothing' do
          expect(result).to be_a KeySet::None
          expect(result.object_id).not_to eq key_set.object_id
        end
      end

      context 'KeySet.some([key1, key3]).remove(KeySet.none)' do
        let(:result) { key_set.remove(described_class.none) }

        it 'we have some, we remove nothing => we have the same set' do
          expect(result).to be_a KeySet::Some
          expect(result.keys.to_a).to eq key_set.keys.to_a
          expect(result.object_id).not_to eq key_set.object_id
        end
      end

      context 'KeySet.some([key1, key3]).remove(KeySet.some [key1, key2])' do
        let(:result) { key_set.remove(described_class.some([key1, key2])) }

        it 'we have some, we remove some others (that does not include our entire set) => we have the keys that we have not been removed' do
          expect(result).to be_a KeySet::Some
          expect(result.object_id).not_to eq key_set.object_id

          other_keys = [key1, key2]
          this_keys = key_set.keys.to_a
          surviving_keys = this_keys - other_keys
          expect(result.keys.to_a).to eq surviving_keys.sort
        end
      end

      context 'KeySet.some([key1, key3]).remove(KeySet.some [key1, key2, key3])' do
        let(:result) { key_set.remove(described_class.some([key1, key2, key3])) }

        it 'we have some, we remove some others that includes our entire set => we have nothing' do
          expect(result).to be_a KeySet::None
          expect(result.object_id).not_to eq key_set.object_id
        end
      end

      context 'KeySet.some([key1, key3]).remove(KeySet.all_except_some [key1, key2])' do
        let(:result) { key_set.remove(described_class.all_except_some([key1, key2])) }

        it 'we have some, we remove all except others => we have only the keys that we had and they were excluded from the removal' do
          expect(result).to be_a KeySet::Some
          expect(result.object_id).not_to eq key_set.object_id

          expect(result.keys.to_a).to eq [key1]
        end
      end

      context 'KeySet.some([key1, key3]).remove(KeySet.all_except_some [key1, key2, key3])' do
        let(:result) { key_set.remove(described_class.all_except_some([key1, key2, key3])) }

        it 'we have some, we remove all except others, which include all our keys => we have the same keys' do
          expect(result).to be_a KeySet::Some
          expect(result.object_id).not_to eq key_set.object_id
          expect(result.keys.to_a).to eq key_set.keys.to_a
        end
      end

      context 'KeySet.some([key1, key3]).remove(KeySet.all_except_some [key2, key4])' do
        let(:result) { key_set.remove(described_class.all_except_some([key2, key4])) }

        it 'we have some, we remove all except others, none of them are in our keys => we have nothing' do
          expect(result).to be_a KeySet::None
          expect(result.object_id).not_to eq key_set.object_id
        end
      end

      context 'KeySet.some([key1, key3]).remove([key1, key2])' do
        it do
          expect { key_set.remove([key1, key2]) }.to raise_error(ArgumentError)
        end
      end
    end

    context 'AllExceptSome' do
      subject(:key_set) { described_class.all_except_some([key1, key3]) }

      context 'KeySet.all_except_some([key1, key3]).remove(KeySet.all)' do
        let(:result) { key_set.remove(described_class.all) }

        it 'we have all except some, we remove everything => we have nothing' do
          expect(result).to be_a KeySet::None
          expect(result.object_id).not_to eq key_set.object_id
        end
      end

      context 'KeySet.all_except_some([key1, key3]).remove(KeySet.none)' do
        let(:result) { key_set.remove(described_class.none) }

        it 'we have all except some, we remove nothing => we have the same (all but these keys)' do
          expect(result).to be_a KeySet::AllExceptSome
          expect(result.keys.to_a).to eq key_set.keys.to_a
          expect(result.object_id).not_to eq key_set.object_id
        end
      end

      context 'KeySet.all_except_some([key1, key3]).remove(KeySet.some [key1, key2])' do
        let(:result) { key_set.remove(described_class.some([key1, key2])) }

        it "we have all except some, we remove some others => we have all except the ones that we didn't have before and the ones that we don't have now" do
          expect(result).to be_a KeySet::AllExceptSome
          expect(result.object_id).not_to eq key_set.object_id

          other_keys = [key1, key2]
          this_keys = key_set.keys.to_a
          union = this_keys + other_keys
          expect(result.keys.to_a).to eq union.uniq.sort
        end
      end

      context 'KeySet.all_except_some([key1, key3]).remove(KeySet.some [key1, key2, key3])' do
        let(:result) { key_set.remove(described_class.some([key1, key2, key3])) }

        it 'we have all except some, we remove some others that includes our entire set => we have all except the new set (that includes the old set)' do
          expect(result).to be_a KeySet::AllExceptSome
          expect(result.object_id).not_to eq key_set.object_id

          other_keys = [key1, key2, key3]
          expect(result.keys.to_a).to eq other_keys.sort
        end
      end

      context 'KeySet.all_except_some([key1, key3]).remove(KeySet.all_except_some [key1, key2])' do
        let(:result) { key_set.remove(described_class.all_except_some([key1, key2])) }

        it 'we have all except some, we remove all except others (that includes some of the current set) => we have only the ones that OTHER did not remove, except the ones that THIS was excluding' do
          expect(result).to be_a KeySet::Some
          expect(result.object_id).not_to eq key_set.object_id

          other_keys = [key1, key2]
          other_keys_not_in_current_keys = other_keys.to_a - key_set.keys.to_a

          expect(result.keys.to_a).to eq other_keys_not_in_current_keys
        end
      end

      context 'KeySet.all_except_some([key1, key3]).remove(KeySet.all_except_some [key1, key2, key3])' do
        let(:result) { key_set.remove(described_class.all_except_some([key1, key2, key3])) }

        it 'we have all except some, we remove all except others (that includes the entire of the current set) => we have only the ones that OTHER did not remove, except the ones that THIS was excluding' do
          expect(result).to be_a KeySet::Some
          expect(result.object_id).not_to eq key_set.object_id

          other_keys = [key1, key2, key3]
          other_keys_not_in_current_keys = other_keys.to_a - key_set.keys.to_a

          expect(result.keys.to_a).to eq other_keys_not_in_current_keys
        end
      end

      context 'KeySet.all_except_some([key1, key3]).remove(KeySet.all_except_some [key2, key4])' do
        let(:result) { key_set.remove(described_class.all_except_some([key2, key4])) }

        it 'we have all except some, we remove all except others (that includes none of the current set) => we get only the ones that the other is not excluding' do
          expect(result).to be_a KeySet::Some
          expect(result.object_id).not_to eq key_set.object_id

          other_keys = [key2, key4]

          expect(result.keys.to_a).to eq other_keys.to_a.sort
        end
      end

      context 'KeySet.all_except_some([key1, key3]).remove(KeySet.all_except_some [key1, key3])' do
        let(:result) { key_set.remove(described_class.all_except_some([key1, key3])) }

        it 'we have all except some, we remove all except others (that has the same set) => we get nothing' do
          expect(result).to be_a KeySet::None
          expect(result.object_id).not_to eq key_set.object_id
        end
      end

      context 'KeySet.all_except_some([key1, key3]).remove([key1, key2])' do
        it do
          expect { key_set.remove([key1, key2]) }.to raise_error(ArgumentError)
        end
      end
    end
  end

  describe '#intersect' do
    context 'All' do
      subject(:key_set) { described_class.all }

      context 'KeySet.all.intersect(KeySet.all)' do
        let(:result) { key_set.intersect(described_class.all) }

        it 'we have everything, we intersect everything => we have everything' do
          expect(result).to be_a KeySet::All
          expect(result.object_id).not_to eq key_set.object_id
        end
      end

      context 'KeySet.all.intersect(KeySet.none)' do
        let(:result) { key_set.intersect(described_class.none) }

        it 'we have everything, we intersect nothing => we have nothing' do
          expect(result).to be_a KeySet::None
          expect(result.object_id).not_to eq key_set.object_id
        end
      end

      context 'KeySet.all.intersect(KeySet.some [key1, key2])' do
        let(:result) { key_set.intersect(described_class.some([key1, key2])) }

        it 'we have everything, we intersect some => we have some' do
          expect(result).to be_a KeySet::Some
          expect(result.keys.to_a).to eq [key1, key2]
          expect(result.object_id).not_to eq key_set.object_id
        end
      end

      context 'KeySet.all.intersect(KeySet.all_except_some [key1, key2])' do
        let(:result) { key_set.intersect(described_class.all_except_some([key1, key2])) }

        it 'we have everything, we intersect all except some => we have all except some' do
          expect(result).to be_a KeySet::AllExceptSome
          expect(result.keys.to_a).to eq [key1, key2]
          expect(result.object_id).not_to eq key_set.object_id
        end
      end

      context 'KeySet.all.intersect([key1, key2])' do
        it do
          expect { key_set.intersect([key1, key2]) }.to raise_error(ArgumentError)
        end
      end
    end

    context 'None' do
      subject(:key_set) { described_class.none }

      context 'KeySet.none.intersect(KeySet.all)' do
        let(:result) { key_set.intersect(described_class.all) }

        it 'we have nothing, we intersect everything => we have nothing' do
          expect(result).to be_a KeySet::None
          expect(result.object_id).not_to eq key_set.object_id
        end
      end

      context 'KeySet.none.intersect(KeySet.none)' do
        let(:result) { key_set.intersect(described_class.none) }

        it 'we have nothing, we intersect nothing => we have nothing' do
          expect(result).to be_a KeySet::None
          expect(result.object_id).not_to eq key_set.object_id
        end
      end

      context 'KeySet.none.intersect(KeySet.some [key1, key2])' do
        let(:result) { key_set.intersect(described_class.some([key1, key2])) }

        it 'we have nothing, we intersect some => we have nothing' do
          expect(result).to be_a KeySet::None
          expect(result.object_id).not_to eq key_set.object_id
        end
      end

      context 'KeySet.none.intersect(KeySet.all_except_some [key1, key2])' do
        let(:result) { key_set.intersect(described_class.all_except_some([key1, key2])) }

        it 'we have nothing, we intersect all except some => we have nothing' do
          expect(result).to be_a KeySet::None
          expect(result.object_id).not_to eq key_set.object_id
        end
      end

      context 'KeySet.none.intersect([key1, key2])' do
        it do
          expect { key_set.intersect([key1, key2]) }.to raise_error(ArgumentError)
        end
      end
    end

    context 'Some' do
      subject(:key_set) { described_class.some([key1, key3]) }

      context 'KeySet.some([key1, key3]).intersect(KeySet.all)' do
        let(:result) { key_set.intersect(described_class.all) }

        it 'we have some, we intersect everything => we have the same some' do
          expect(result).to be_a KeySet::Some
          expect(result.keys.to_a).to eq key_set.keys.to_a
          expect(result.object_id).not_to eq key_set.object_id
        end
      end

      context 'KeySet.some([key1, key3]).intersect(KeySet.none)' do
        let(:result) { key_set.intersect(described_class.none) }

        it 'we have some, we intersect nothing => we have nothing' do
          expect(result).to be_a KeySet::None
          expect(result.object_id).not_to eq key_set.object_id
        end
      end

      context 'KeySet.some([key1, key3]).intersect(KeySet.some [key1, key2])' do
        let(:result) { key_set.intersect(described_class.some([key1, key2])) }

        it 'we have some, we intersect some others (that does not include our entire set) => we have the common keys' do
          expect(result).to be_a KeySet::Some
          expect(result.object_id).not_to eq key_set.object_id

          other_keys = [key1, key2]
          this_keys = key_set.keys.to_a
          surviving_keys = this_keys & other_keys
          expect(result.keys.to_a).to eq surviving_keys.sort
          expect(result.keys.to_a).to eq [key1]
        end
      end

      context 'KeySet.some([key1, key3]).intersect(KeySet.some [key1, key2, key3])' do
        let(:result) { key_set.intersect(described_class.some([key1, key2, key3])) }

        it 'we have some, we intersect some others that includes our entire set => we have the common keys, so our former set' do
          expect(result).to be_a KeySet::Some
          expect(result.object_id).not_to eq key_set.object_id

          expect(result.keys.to_a).to eq key_set.keys.sort
        end
      end

      context 'KeySet.some([key1, key3]).intersect(KeySet.all_except_some [key1, key2])' do
        let(:result) { key_set.intersect(described_class.all_except_some([key1, key2])) }

        it 'we have some, we intersect all except others, which includes some of ours => we have the former keys that are not in the other keys' do
          expect(result).to be_a KeySet::Some
          expect(result.object_id).not_to eq key_set.object_id

          expect(result.keys.to_a).to eq [key3]
        end
      end

      context 'KeySet.some([key1, key3]).intersect(KeySet.all_except_some [key1, key2, key3])' do
        let(:result) { key_set.intersect(described_class.all_except_some([key1, key2, key3])) }

        it 'we have some, we intersect all except others, which include all our keys => we have nothing' do
          expect(result).to be_a KeySet::None
          expect(result.object_id).not_to eq key_set.object_id
        end
      end

      context 'KeySet.some([key1, key3]).intersect(KeySet.all_except_some [key2, key4])' do
        let(:result) { key_set.intersect(described_class.all_except_some([key2, key4])) }

        it 'we have some, we intersect all except others, none of them are in our keys => we have the same set' do
          expect(result).to be_a KeySet::Some
          expect(result.object_id).not_to eq key_set.object_id
          expect(result.keys.to_a).to eq key_set.keys.to_a
        end
      end

      context 'KeySet.some([key1, key3]).intersect([key1, key2])' do
        it do
          expect { key_set.intersect([key1, key2]) }.to raise_error(ArgumentError)
        end
      end
    end

    context 'AllExceptSome' do
      subject(:key_set) { described_class.all_except_some([key1, key3]) }

      context 'KeySet.all_except_some([key1, key3]).intersect(KeySet.all)' do
        let(:result) { key_set.intersect(described_class.all) }

        it 'we have all except some, we intersect everything => we have the same' do
          expect(result).to be_a KeySet::AllExceptSome
          expect(result.object_id).not_to eq key_set.object_id
          expect(result.keys.to_a).to eq key_set.keys.to_a
        end
      end

      context 'KeySet.all_except_some([key1, key3]).intersect(KeySet.none)' do
        let(:result) { key_set.intersect(described_class.none) }

        it 'we have all except some, we intersect nothing => we have none' do
          expect(result).to be_a KeySet::None
          expect(result.object_id).not_to eq key_set.object_id
        end
      end

      context 'KeySet.all_except_some([key1, key3]).intersect(KeySet.some [key1, key2])' do
        let(:result) { key_set.intersect(described_class.some([key1, key2])) }

        it 'we have all except some, we intersect some others => we have the keys in the second that area not in the keys of the first' do
          expect(result).to be_a KeySet::Some
          expect(result.object_id).not_to eq key_set.object_id

          expect(result.keys.to_a).to eq [key2]
        end
      end

      context 'KeySet.all_except_some([key1, key3]).intersect(KeySet.some [key1, key3])' do
        let(:result) { key_set.intersect(described_class.some([key1, key3])) }

        it 'we have all except some, we intersect some of the same keys => we have nothing' do
          expect(result).to be_a KeySet::None
          expect(result.object_id).not_to eq key_set.object_id
        end
      end

      context 'KeySet.all_except_some([key1, key3]).intersect(KeySet.some [key1, key2, key3])' do
        let(:result) { key_set.intersect(described_class.some([key1, key2, key3])) }

        it 'we have all except some, we intersect some others that includes our entire set => we have the keys in the second that area not in the keys of the first' do
          expect(result).to be_a KeySet::Some
          expect(result.object_id).not_to eq key_set.object_id

          expect(result.keys.to_a).to eq [key2]
        end
      end

      context 'KeySet.all_except_some([key1, key3]).intersect(KeySet.all_except_some [key1, key2])' do
        let(:result) { key_set.intersect(described_class.all_except_some([key1, key2])) }

        it 'we have all except some, we intersect all except others (that includes some of the current set) => we get all except the union of keys in the first and in the second' do
          expect(result).to be_a KeySet::AllExceptSome
          expect(result.object_id).not_to eq key_set.object_id

          expect(result.keys.to_a).to eq [key1, key2, key3].sort
        end
      end

      context 'KeySet.all_except_some([key1, key3]).intersect(KeySet.all_except_some [key1, key2, key3])' do
        let(:result) { key_set.intersect(described_class.all_except_some([key1, key2, key3])) }

        it 'we have all except some, we intersect all except others (that includes the entire of the current set) => we get all except the union of keys in the first and in the second' do
          expect(result).to be_a KeySet::AllExceptSome
          expect(result.object_id).not_to eq key_set.object_id

          expect(result.keys.to_a).to eq [key1, key2, key3].sort
        end
      end

      context 'KeySet.all_except_some([key1, key3]).intersect(KeySet.all_except_some [key2, key4])' do
        let(:result) { key_set.intersect(described_class.all_except_some([key2, key4])) }

        it 'we have all except some, we intersect all except others (that includes none of the current set) => we get all except the union of keys in the first and in the second' do
          expect(result).to be_a KeySet::AllExceptSome
          expect(result.object_id).not_to eq key_set.object_id

          expect(result.keys.to_a).to eq [key1, key2, key3, key4].sort
        end
      end

      context 'KeySet.all_except_some([key1, key3]).intersect(KeySet.all_except_some [key1, key3])' do
        let(:result) { key_set.intersect(described_class.all_except_some([key1, key3])) }

        it 'we have all except some, we intersect all except others (that has the same set) => we get the same' do
          expect(result).to be_a KeySet::AllExceptSome
          expect(result.object_id).not_to eq key_set.object_id
          expect(result.keys.to_a).to eq key_set.keys.to_a
        end
      end

      context 'KeySet.all_except_some([key1, key3]).intersect([key1, key2])' do
        it do
          expect { key_set.intersect([key1, key2]) }.to raise_error(ArgumentError)
        end
      end
    end
  end

  describe 'equal if they are of the same class and have the same elements (if applicable)' do
    context 'All' do
      let(:a) { described_class.all }
      let(:a_keys) { [1, 2, 3] }
      let(:b_keys) { [2, 3, 4] }

      context 'vs All' do
        let(:b) { described_class.all }

        context '#==' do
          it { expect(a == b).to be_truthy }
        end

        context '#===' do
          it { expect(a === b).to be_truthy }
        end

        context '#<=>' do
          it { expect(a <=> b).to eq 0 }
        end

        context '#eql?' do
          it { expect(a).to be_eql b }
        end
      end

      context 'vs None' do
        let(:b) { described_class.none }

        context '#==' do
          it { expect(a == b).to be_falsey }
        end

        context '#===' do
          it { expect(a === b).to be_falsey }
        end

        context '#<=>' do
          it { expect(a <=> b).to eq 1 }
        end

        context '#eql?' do
          it { expect(a).not_to be_eql b }
        end
      end

      context 'vs Some' do
        let(:b) { described_class.some b_keys }

        context '#==' do
          it { expect(a == b).to be_falsey }
        end

        context '#===' do
          it { expect(a === b).to be_falsey }
        end

        context '#<=>' do
          it { expect(a <=> b).to eq 1 }
        end

        context '#eql?' do
          it { expect(a).not_to be_eql b }
        end
      end

      context 'vs AllExceptSome' do
        let(:b) { described_class.all_except_some b_keys }

        context '#==' do
          it { expect(a == b).to be_falsey }
        end

        context '#===' do
          it { expect(a === b).to be_falsey }
        end

        context '#<=>' do
          it { expect(a <=> b).to eq 1 }
        end

        context '#eql?' do
          it { expect(a).not_to be_eql b }
        end
      end
    end

    context 'None' do
      let(:a) { described_class.none }
      let(:a_keys) { [1, 2, 3] }
      let(:b_keys) { [2, 3, 4] }

      context 'vs All' do
        let(:b) { described_class.all }

        context '#==' do
          it { expect(a == b).to be_falsey }
        end

        context '#===' do
          it { expect(a === b).to be_falsey }
        end

        context '#<=>' do
          it { expect(a <=> b).to eq(-1) }
        end

        context '#eql?' do
          it { expect(a).not_to be_eql b }
        end
      end

      context 'vs None' do
        let(:b) { described_class.none }

        context '#==' do
          it { expect(a == b).to be_truthy }
        end

        context '#===' do
          it { expect(a === b).to be_truthy }
        end

        context '#<=>' do
          it { expect(a <=> b).to eq 0 }
        end

        context '#eql?' do
          it { expect(a).to be_eql b }
        end
      end

      context 'vs Some' do
        let(:b) { described_class.some b_keys }

        context '#==' do
          it { expect(a == b).to be_falsey }
        end

        context '#===' do
          it { expect(a === b).to be_falsey }
        end

        context '#<=>' do
          it { expect(a <=> b).to eq(-1) }
        end

        context '#eql?' do
          it { expect(a).not_to be_eql b }
        end
      end

      context 'vs AllExceptSome' do
        let(:b) { described_class.all_except_some b_keys }

        context '#==' do
          it { expect(a == b).to be_falsey }
        end

        context '#===' do
          it { expect(a === b).to be_falsey }
        end

        context '#<=>' do
          it { expect(a <=> b).to eq(-1) }
        end

        context '#eql?' do
          it { expect(a).not_to be_eql b }
        end
      end
    end

    context 'Some' do
      let(:a) { described_class.some a_keys }
      let(:a_keys) { [1, 2, 3] }
      let(:b_keys) { [2, 3, 4] }

      context 'vs All' do
        let(:b) { described_class.all }

        context '#==' do
          it { expect(a == b).to be_falsey }
        end

        context '#===' do
          it { expect(a === b).to be_falsey }
        end

        context '#<=>' do
          it { expect(a <=> b).to eq(-1) }
        end

        context '#eql?' do
          it { expect(a).not_to be_eql b }
        end
      end

      context 'vs None' do
        let(:b) { described_class.none }

        context '#==' do
          it { expect(a == b).to be_falsey }
        end

        context '#===' do
          it { expect(a === b).to be_falsey }
        end

        context '#<=>' do
          it { expect(a <=> b).to eq 1 }
        end

        context '#eql?' do
          it { expect(a).not_to be_eql b }
        end
      end

      context 'vs Some' do
        let(:b) { described_class.some b_keys }

        context 'with the same keys' do
          let(:b_keys) { a_keys.dup }

          context '#==' do
            it { expect(a == b).to be_truthy }
          end

          context '#===' do
            it { expect(a === b).to be_truthy }
          end

          context '#<=>' do
            it { expect(a <=> b).to eq 0 }
          end

          context '#eql?' do
            it { expect(a).to be_eql b }
          end
        end

        context 'with different keys, starting lower' do
          let(:b_keys) { [0, 1, 5] }

          context '#==' do
            it { expect(a == b).to be_falsey }
          end

          context '#===' do
            it { expect(a === b).to be_falsey }
          end

          context '#<=>' do
            it { expect(a <=> b).to eq 1 }
          end

          context '#eql?' do
            it { expect(a).not_to be_eql b }
          end
        end

        context 'with different keys, starting higher' do
          let(:b_keys) { [3, 4, 5] }

          context '#==' do
            it { expect(a == b).to be_falsey }
          end

          context '#===' do
            it { expect(a === b).to be_falsey }
          end

          context '#<=>' do
            it { expect(a <=> b).to eq(-1) }
          end

          context '#eql?' do
            it { expect(a).not_to be_eql b }
          end
        end
      end

      context 'vs AllExceptSome' do
        let(:b) { described_class.all_except_some a_keys }

        context '#==' do
          it { expect(a == b).to be_falsey }
        end

        context '#===' do
          it { expect(a === b).to be_falsey }
        end

        context '#<=>' do
          it { expect(a <=> b).to eq(-1) }
        end

        context '#eql?' do
          it { expect(a).not_to be_eql b }
        end
      end
    end

    context 'AllExceptSome' do
      let(:a) { described_class.all_except_some a_keys }
      let(:a_keys) { [1, 2, 3] }
      let(:b_keys) { [2, 3, 4] }

      context 'vs All' do
        let(:b) { described_class.all }

        context '#==' do
          it { expect(a == b).to be_falsey }
        end

        context '#===' do
          it { expect(a === b).to be_falsey }
        end

        context '#<=>' do
          it { expect(a <=> b).to eq(-1) }
        end

        context '#eql?' do
          it { expect(a).not_to be_eql b }
        end
      end

      context 'vs None' do
        let(:b) { described_class.none }

        context '#==' do
          it { expect(a == b).to be_falsey }
        end

        context '#===' do
          it { expect(a === b).to be_falsey }
        end

        context '#<=>' do
          it { expect(a <=> b).to eq 1 }
        end

        context '#eql?' do
          it { expect(a).not_to be_eql b }
        end
      end

      context 'vs Some' do
        let(:b) { described_class.some a_keys }

        context '#==' do
          it { expect(a == b).to be_falsey }
        end

        context '#===' do
          it { expect(a === b).to be_falsey }
        end

        context '#<=>' do
          it { expect(a <=> b).to eq 1 }
        end

        context '#eql?' do
          it { expect(a).not_to be_eql b }
        end
      end

      context 'vs AllExceptSome' do
        let(:b) { described_class.all_except_some b_keys }

        context 'with the same keys' do
          let(:b_keys) { a_keys.dup }

          context '#==' do
            it { expect(a == b).to be_truthy }
          end

          context '#===' do
            it { expect(a === b).to be_truthy }
          end

          context '#<=>' do
            it { expect(a <=> b).to eq 0 }
          end

          context '#eql?' do
            it { expect(a).to be_eql b }
          end
        end

        context 'with different keys, starting lower' do
          let(:b_keys) { [0, 1, 5] }

          context '#==' do
            it { expect(a == b).to be_falsey }
          end

          context '#===' do
            it { expect(a === b).to be_falsey }
          end

          context '#<=>' do
            it { expect(a <=> b).to eq 1 }
          end

          context '#eql?' do
            it { expect(a).not_to be_eql b }
          end
        end

        context 'with different keys, starting higher' do
          let(:b_keys) { [3, 4, 5] }

          context '#==' do
            it { expect(a == b).to be_falsey }
          end

          context '#===' do
            it { expect(a === b).to be_falsey }
          end

          context '#<=>' do
            it { expect(a <=> b).to eq(-1) }
          end

          context '#eql?' do
            it { expect(a).not_to be_eql b }
          end
        end
      end
    end
  end

  describe '#clone' do
    context 'KeySet.all.clone' do
      subject(:key_set) { described_class.all }

      let(:result) { key_set.clone }

      it { expect(result).to be_a KeySet::All }
      it { expect(result.object_id).not_to eq key_set.object_id }
      it { expect(result.hash).to eq key_set.hash }
    end

    context 'KeySet.none.clone' do
      subject(:key_set) { described_class.none }

      let(:result) { key_set.clone }

      it { expect(result).to be_a KeySet::None }
      it { expect(result.object_id).not_to eq key_set.object_id }
      it { expect(result.hash).to eq key_set.hash }
    end

    context 'KeySet.some([key1, key2]).clone' do
      subject(:key_set) { described_class.some([key1, key2]) }

      let(:result) { key_set.clone }

      it { expect(result).to be_a KeySet::Some }
      it { expect(result.object_id).not_to eq key_set.object_id }
      it { expect(result.hash).to eq key_set.hash }
      it { expect(result.keys).to eq key_set.keys }
      it { expect(result.keys.object_id).not_to eq key_set.keys.object_id }
    end

    context 'KeySet.all_except_some([key1, key2]).clone' do
      subject(:key_set) { described_class.all_except_some([key1, key2]) }

      let(:result) { key_set.clone }

      it { expect(result).to be_a KeySet::AllExceptSome }
      it { expect(result.object_id).not_to eq key_set.object_id }
      it { expect(result.hash).to eq key_set.hash }
      it { expect(result.keys).to eq key_set.keys }
      it { expect(result.keys.object_id).not_to eq key_set.keys.object_id }
    end
  end

  describe '#invert' do
    context 'All' do
      subject(:key_set) { described_class.all }

      it 'we get KeySet.none' do
        expect(key_set.invert).to be_a KeySet::None
      end
    end

    context 'None' do
      subject(:key_set) { described_class.none }

      it 'we get KeySet.all' do
        expect(key_set.invert).to be_a KeySet::All
      end
    end

    context 'Some' do
      subject(:key_set) { described_class.some(keys) }

      let(:keys) { [1, 3, 4] }

      it 'we get KeySet.all_except_some with same keys' do
        # @type [KeySet::AllExceptSome]
        result = key_set.invert
        expect(result).to be_a KeySet::AllExceptSome
        expect(result.keys_array).to eq keys.sort
      end
    end

    context 'AllExceptSome' do
      subject(:key_set) { described_class.all_except_some(keys) }

      let(:keys) { [1, 3, 4] }

      it 'we get KeySet.some with same keys' do
        # @type [KeySet::Some]
        result = key_set.invert
        expect(result).to be_a KeySet::Some
        expect(result.keys_array).to eq keys.sort
      end
    end
  end
end
# rubocop:enable Style/CaseEquality
