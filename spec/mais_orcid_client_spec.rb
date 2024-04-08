# frozen_string_literal: true

require 'ostruct'

RSpec.describe MaisOrcidClient do
  # NOTE: This spec uses vcr cassettes from the MAIS API that were edited to obscure access tokens.
  #   The 500 test is also hard to replicate since the API does not return 500s typically.
  #   If the cassettes are re-created, you need to edit the access tokens in the cassette files
  #   and in the expectations below.

  subject do
    described_class.configure(
      client_id: FAKE_CLIENT_ID,
      client_secret: FAKE_CLIENT_SECRET,
      base_url: 'https://aswsuat.stanford.edu'
    )
  end

  describe '#fetch_orcid_users' do
    let(:orcid_users) { subject.fetch_orcid_users(limit: 5, page_size: 2) }

    # rubocop:disable RSpec/ExampleLength
    it 'retrieves users' do
      VCR.use_cassette('Mais_Client/_fetch_orcid_users/retrieves users') do
        expect(orcid_users.size).to eq(5)
        expect(orcid_users.first).to eq(MaisOrcidClient::OrcidUser.new('nataliex',
                                                                       'https://sandbox.orcid.org/0000-0001-7161-1827',
                                                                       ['/read-limited'],
                                                                       'XXXXXXXX-1ac5-4ea7-835d-bc6d61ffb9a8',
                                                                       '2020-01-23T17:06:21.000'))
      end
    end

    context 'when server returns 500' do
      it 'raises ServerError' do
        VCR.use_cassette('Mais_Client/_fetch_orcid_users/raises') do
          expect { orcid_users }.to raise_error(MaisOrcidClient::UnexpectedResponse::ServerError)
        end
      end
    end
  end

  describe '#fetch_orcid_user' do
    let(:orcid_user_by_sunetid) { subject.fetch_orcid_user(sunetid: 'nataliex') }
    let(:bad_orcid_user_by_sunetid) { subject.fetch_orcid_user(sunetid: 'totally-bogus') }
    let(:orcid_user_by_orcidid) { subject.fetch_orcid_user(orcidid: 'https://sandbox.orcid.org/0000-0002-5466-7797') }
    let(:bare_orcid_user_by_orcidid) { subject.fetch_orcid_user(orcidid: '0000-0002-5466-7797') }
    let(:bogus_orcid_user_by_orcidid) { subject.fetch_orcid_user(orcidid: 'totally-bogus') }
    let(:bad_orcid_user_by_orcidid) { subject.fetch_orcid_user(orcidid: 'https://sandbox.orcid.org/0000-0002-5466-7798') }
    let(:no_ids_provided) { subject.fetch_orcid_user }

    it 'retrieves a single user by sunetid' do
      VCR.use_cassette('Mais_Client/_fetch_orcid_user/retrieves user') do
        expect(orcid_user_by_sunetid).to eq(MaisOrcidClient::OrcidUser.new('nataliex',
                                                                           'https://sandbox.orcid.org/0000-0001-7161-1827',
                                                                           ['/read-limited'],
                                                                           'XXXXXXXX-1ac5-4ea7-835d-bc6d61ffb9a8',
                                                                           '2020-01-23T17:06:21.000'))
      end
    end

    context 'when a sunetid user is not found' do
      it 'returns nil' do
        VCR.use_cassette('Mais_Client/_fetch_orcid_user/raises') do
          expect(bad_orcid_user_by_sunetid).to be_nil
        end
      end
    end

    it 'retrieves a single user by orcidid' do
      VCR.use_cassette('Mais_Client/_fetch_orcid_user/retreives user by orcidid') do
        expect(orcid_user_by_orcidid).to eq(MaisOrcidClient::OrcidUser.new('vivnwong',
                                                                           'https://sandbox.orcid.org/0000-0002-5466-7797',
                                                                           ['/read-limited', '/activities/update',
                                                                            '/person/update'],
                                                                           'XXXXXXXX-7e60-4f7b-b7d4-4bd21d9c5618',
                                                                           '2021-05-28T09:50:14.000'))
      end
    end

    it 'retrieves a single user by orcidid when a bare orcid is passed in' do
      VCR.use_cassette('Mais_Client/_fetch_orcid_user/retreives user by orcidid') do
        expect(bare_orcid_user_by_orcidid).to eq(MaisOrcidClient::OrcidUser.new('vivnwong',
                                                                                'https://sandbox.orcid.org/0000-0002-5466-7797',
                                                                                ['/read-limited', '/activities/update',
                                                                                 '/person/update'],
                                                                                'XXXXXXXX-7e60-4f7b-b7d4-4bd21d9c5618',
                                                                                '2021-05-28T09:50:14.000'))
      end
    end
    # rubocop:enable RSpec/ExampleLength

    context 'when an orcidid user is not found' do
      it 'returns nil' do
        VCR.use_cassette('Mais_Client/_fetch_orcid_user/raises by orcidid') do
          expect(bad_orcid_user_by_orcidid).to be_nil
        end
      end
    end

    context 'when an orcidid is invalid' do
      it 'returns nil' do
        VCR.use_cassette('Mais_Client/_fetch_orcid_user/retrieves user') do
          expect(bogus_orcid_user_by_orcidid).to be_nil
        end
      end
    end

    context 'when sunetid or orcidid not provided' do
      it 'raises an exception' do
        expect { no_ids_provided }.to raise_error(StandardError)
      end
    end
  end
end
