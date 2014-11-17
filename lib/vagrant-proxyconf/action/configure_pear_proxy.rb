require_relative 'base'

module VagrantPlugins
  module ProxyConf
    class Action
      # Action for configuring Pear on the guest
      class ConfigurePearProxy < Base
        def config_name
          'pear_proxy'
        end

        private

        # @return [Vagrant::Plugin::V2::Config] the configuration
        def config
          # Use global proxy config
          @config ||= finalize_config(@machine.config.proxy)
        end

        def configure_machine
          proxy = config.http || ''

          @machine.communicate.sudo(
            "#{pear_path} config-set http_proxy #{escape(proxy)} system")
        end

        def pear_path
          @machine.guest.capability(cap_name)
        end
      end
    end
  end
end
