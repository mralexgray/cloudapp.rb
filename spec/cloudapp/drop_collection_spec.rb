require 'helper'
require 'ostruct'

require 'cloudapp/drop_collection'

describe CloudApp::DropCollection do
  let(:response)   {[{ name: 'one' }, { name: 'two' }]}
  let(:drop_class) { OpenStruct }
  subject { CloudApp::DropCollection.new response, drop_class }

  it 'is a collection of drops' do
    subject.size.should eq(response.size)
    response.each_with_index do |drop, index|
      subject[index].name.should eq(drop[:name])
    end
  end

  it 'decodes each drop' do
    response.each do |drop|
      drop_class.should_receive(:new).with(drop)
    end
    subject
  end

  it 'is authorized' do
    subject.should_not be_unauthorized
  end

  it 'is successful' do
    subject.should be_successful
  end

  context 'an unauthorized response' do
    let(:response) { :unauthorized }

    it 'is unauthorized' do
      subject.should be_unauthorized
    end

    it 'is an empty array' do
      subject.should be_empty
    end
  end

  describe '#link' do
    let(:link_name) { stub :link_name }
    let(:href_s)    { stub :href_s }
    let(:href)      { stub :href, to_s: href_s }
    let(:link)      { stub :link, href: href }
    before do response.stub(link: link) end

    it 'returns the stringified href' do
      subject.link(link_name).should eq(href_s)
    end

    it 'delegates to the response' do
      response.should_receive(:link).with(link_name)
      subject.link link_name
    end

    it 'falls back to a nil link' do
      response.stub(:link) do |name, fallback|
        fallback.call.should be_nil
        link
      end

      subject.link link_name
    end

    it 'returns nil for a nonexistent link' do
      response.stub link: nil
      subject.link(link_name).should be_nil
    end
  end
end
