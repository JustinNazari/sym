require 'spec_helper'
require 'secrets/cipher/base64/encrypted_data'

describe Secrets::Cipher::Base64::EncryptedData do
  let(:secret) { data_class.create_secret }
  let(:data_class) { Secrets::Cipher::Base64::EncryptedData }
  let(:phrase) { 'hello world' }
  let(:data1) { data_class.new(decrypted: phrase, secret: secret) }
  let(:data2) { data_class.new(encrypted: data1.encrypted, secret: secret) }

  context '#initialize' do
    context 'decrypted initialization' do
      subject { data1 }
      it { is_expected.to respond_to(:decrypted) }
    end
    context 'data.encrypted' do
      subject { data1.encrypted }
      it { is_expected.not_to eql(phrase) }
    end
    context 'data2.decrypted' do
      subject { data2.decrypted }
      it { is_expected.to eql(phrase) }
    end
    context 'secret' do
      subject { ::Base64.decode64(secret).length }
      it { is_expected.to eql(32) }
    end
    context 'autogenerated secret' do
      let(:secret) { nil }
      let(:data3) { data_class.new(decrypted: phrase, secret: data1.secret) }
      context 'decrypting' do
        subject { data3.decrypted }
        it { is_expected.to eql(phrase) }
      end
      context 'secret passing' do
        it 'should correctly assign the same secret' do
          expect(data3.secret).to eql(data1.secret)
        end
      end
    end
  end
end
