module Sisimai
  # Sisimai::Order::Email makes optimized order list which include MTA, MSP and
  # CED modules to be loaded on first from MTA, MSP or CED specific headers in
  # the bounce mail headers such as X-Failed-Recipients.
  # This module are called from only Sisimai::Message::Email.
  module Order
    module Email
      # Imported from p5-Sisimail/lib/Sisimai/Order/Email.pm
      class << self
        require 'sisimai/mta'
        require 'sisimai/msp'
        require 'sisimai/ced'

        EngineOrder1 = [
          # These modules have many subject patterns or have MIME encoded subjects
          # which is hard to code as regular expression
          'Sisimai::MTA::Exim',
          'Sisimai::MTA::Exchange2003',
        ]
        EngineOrder2 = [
          # These modules have no MTA specific header and did not listed in the
          # following subject header based regular expressions.
          'Sisimai::MTA::Exchange2007',
          'Sisimai::MSP::US::Facebook',
          'Sisimai::MSP::JP::KDDI',
        ]
        EngineOrder3 = [
          # These modules have no MTA specific header but listed in the following
          # subject header based regular expressions.
          'Sisimai::MTA::Qmail',
          'Sisimai::MTA::Notes',
          'Sisimai::MTA::MessagingServer',
          'Sisimai::MTA::Domino',
          'Sisimai::MSP::DE::EinsUndEins',
          'Sisimai::MTA::OpenSMTPD',
          'Sisimai::MTA::MXLogic',
          'Sisimai::MTA::Postfix',
          'Sisimai::MTA::Sendmail',
          'Sisimai::MTA::Courier',
          'Sisimai::MTA::IMailServer',
          'Sisimai::MSP::US::SendGrid',
          'Sisimai::MSP::US::Bigfoot',
          'Sisimai::MTA::X4',
        ]
        EngineOrder4 = [
          # These modules have no MTA specific headers and there are few samples or
          # too old MTA
          'Sisimai::MSP::US::Verizon',
          'Sisimai::MTA::InterScanMSS',
          'Sisimai::MTA::MailFoundry',
          'Sisimai::MTA::ApacheJames',
          'Sisimai::MSP::JP::Biglobe',
          'Sisimai::MSP::JP::EZweb',
          'Sisimai::MTA::X5',
          'Sisimai::MTA::X3',
          'Sisimai::MTA::X2',
          'Sisimai::MTA::X1',
          'Sisimai::MTA::V5sendmail',
        ]
        EngineOrder5 = [
          # These modules have one or more MTA specific headers but other headers
          # also required for detecting MTA name
          'Sisimai::MSP::US::Google',
          'Sisimai::MSP::US::Outlook',
          'Sisimai::MSP::RU::MailRu',
          'Sisimai::MSP::UK::MessageLabs',
          'Sisimai::MTA::MailMarshalSMTP',
          'Sisimai::MTA::MFILTER',
        ]
        EngineOrder9 = [
          # These modules have one or more MTA specific headers
          'Sisimai::MSP::US::Aol',
          'Sisimai::MSP::US::Yahoo',
          'Sisimai::MSP::US::AmazonSES',
          'Sisimai::MSP::DE::GMX',
          'Sisimai::MSP::RU::Yandex',
          'Sisimai::MSP::US::ReceivingSES',
          'Sisimai::MSP::US::Office365',
          'Sisimai::MSP::US::AmazonWorkMail',
          'Sisimai::MSP::US::Zoho',
          'Sisimai::MTA::McAfee',
          'Sisimai::CED::US::AmazonSES',
          'Sisimai::MTA::Activehunter',
          'Sisimai::MTA::SurfControl',
        ]

        # This variable don't hold MTA/MSP name which have one or more MTA specific
        # header such as X-AWS-Outgoing, X-Yandex-Uniq.
        PatternTable = {
          'subject' => {
            %r/delivery/i => [
              'Sisimai::MTA::Exim',
              'Sisimai::MTA::Courier',
              'Sisimai::MSP::US::Google',
              'Sisimai::MSP::US::Outlook',
              'Sisimai::MTA::Domino',
              'Sisimai::MTA::OpenSMTPD',
              'Sisimai::MSP::DE::EinsUndEins',
              'Sisimai::MTA::InterScanMSS',
              'Sisimai::MTA::MailFoundry',
              'Sisimai::MTA::X4',
              'Sisimai::MTA::X3',
              'Sisimai::MTA::X2',
            ],
            %r/noti(?:ce|fi)/i => [
              'Sisimai::MTA::Qmail',
              'Sisimai::MTA::Sendmail',
              'Sisimai::MSP::US::Google',
              'Sisimai::MSP::US::Outlook',
              'Sisimai::MTA::Courier',
              'Sisimai::MTA::MessagingServer',
              'Sisimai::MTA::OpenSMTPD',
              'Sisimai::CED::US::AmazonSES',
              'Sisimai::MTA::X4',
              'Sisimai::MTA::X3',
              'Sisimai::MTA::MFILTER',
            ],
            %r/return/i => [
              'Sisimai::MTA::Postfix',
              'Sisimai::MTA::Sendmail',
              'Sisimai::MSP::US::SendGrid',
              'Sisimai::MSP::US::Bigfoot',
              'Sisimai::MTA::X1',
              'Sisimai::MSP::DE::EinsUndEins',
              'Sisimai::MSP::JP::Biglobe',
              'Sisimai::MTA::V5sendmail',
            ],
            %r/undeliver/i => [
              'Sisimai::MTA::Postfix',
              'Sisimai::MTA::Exchange2007',
              'Sisimai::MTA::Exchange2003',
              'Sisimai::MTA::Notes',
              'Sisimai::MSP::US::Office365',
              'Sisimai::MSP::US::Verizon',
              'Sisimai::MSP::US::SendGrid',
              'Sisimai::MTA::IMailServer',
              'Sisimai::MTA::MailMarshalSMTP',
            ],
            %r/failure/i => [
              'Sisimai::MTA::Qmail',
              'Sisimai::MTA::Domino',
              'Sisimai::MSP::US::Google',
              'Sisimai::MSP::US::Outlook',
              'Sisimai::MSP::RU::MailRu',
              'Sisimai::MTA::X4',
              'Sisimai::MTA::X2',
              'Sisimai::MTA::MFILTER',
            ],
            %r/warning/i => [
              'Sisimai::MTA::Postfix',
              'Sisimai::MTA::Sendmail',
              'Sisimai::MTA::Exim',
            ],
          },
        }

        make_default_order = lambda do
          # Make default order of MTA/MSP and CED modules to be loaded
          rv = []
          begin
            rv.concat(Sisimai::MTA.index.map { |e| 'Sisimai::MTA::' + e })
            rv.concat(Sisimai::MSP.index.map { |e| 'Sisimai::MSP::' + e })
            rv.concat(Sisimai::CED.index.map { |e| 'Sisimai::CED::' + e })
          rescue
            # Failed to load MTA/MSP or CED module
            next
          end
          return rv
        end
        DefaultOrder = make_default_order.call

        # Make default order of MTA/MSP modules to be loaded
        # @return   [Array] Default order list of MTA/MSP modules
        def default
          return DefaultOrder
        end

        # Get regular expression patterns for specified field
        # @param    [String] group  Group name for "ORDER BY"
        # @return   [Hash]          Pattern table for the group
        def by(group = '')
          return {} unless group.size > 0
          return PatternTable[group] if PatternTable.key?(group)
          return {}
        end

        # Make MTA, MSP, and CED module list as a spare
        # @return   [Array] Ordered module list
        def another
          rv = []
          rv.concat(EngineOrder1)
          rv.concat(EngineOrder2)
          rv.concat(EngineOrder3)
          rv.concat(EngineOrder4)
          rv.concat(EngineOrder5)
          rv.concat(EngineOrder9)
          return rv
        end

        # Make email header list in each MTA, MSP, and CED module
        # @return   [Hash] Header list to be parsed
        def headers
          order = self.default
          table = {}
          skips = { 'return-path' => 1, 'x-mailer' => 1 }

          order.each do |e|
            # Load email headers from each MTA,MSP module
            begin
              require e.gsub('::', '/').downcase
            rescue LoadError
              warn ' ***warning: Failed to load ' + e
              next
            end

            Module.const_get(e).headerlist.each do |v|
              # Get header name which required each MTA/MSP module
              q = v.downcase
              next if skips.key?(q)
              table[q]  ||= {}
              table[q][e] = 1
            end
          end
          return table
        end

      end
    end
  end
end

