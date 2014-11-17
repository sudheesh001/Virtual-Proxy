require_relative 'base'

module VagrantPlugins
  module ProxyConf
    class Action
      # Action for configuring proxy environment variables on the guest
      class ConfigureEnvProxy < Base
        def config_name
          'env_proxy'
        end

        private

        def configure_machine
          if windows_guest?
            logger.info('Setting the Windows proxy environment variables')
            configure_machine_windows
          else
            logger.info('Writing the proxy configuration to files')
            super
            write_config(sudo_config, path: '/etc/sudoers.d/proxy', mode: '0440')
            write_environment_config
          end
        end

        def configure_machine_windows
          set_windows_proxy('http_proxy', config.http)
          set_windows_proxy('https_proxy', config.https)
          set_windows_proxy('ftp_proxy', config.ftp)
          set_windows_proxy('no_proxy', config.no_proxy)
        end

        def set_windows_proxy(key, value)
          if value
            command = "cmd.exe /c SETX #{key} #{value.inspect} /M"
            logger.info("Setting #{key} to #{value}")
            @machine.communicate.sudo(command)
          else
            logger.info("Not setting #{key}")
          end
        end

        def windows_guest?
          @machine.config.vm.guest.eql?(:windows)
        end

        def sudo_config
          <<-CONFIG.gsub(/^\s+/, '')
            Defaults env_keep += "HTTP_PROXY HTTPS_PROXY FTP_PROXY NO_PROXY"
            Defaults env_keep += "http_proxy https_proxy ftp_proxy no_proxy"
          CONFIG
        end

        def write_environment_config
          tmp = "/tmp/vagrant-proxyconf"
          path = "/etc/environment"

          sed_script = environment_sed_script
          local_tmp = tempfile(environment_config)

          @machine.communicate.tap do |comm|
            comm.sudo("rm #{tmp}", error_check: false)
            comm.upload(local_tmp.path, tmp)
            comm.sudo("touch #{path}")
            comm.sudo("sed -e '#{sed_script}' #{path} > #{path}.new")
            comm.sudo("cat #{tmp} >> #{path}.new")
            comm.sudo("chmod 0644 #{path}.new")
            comm.sudo("chown root:root #{path}.new")
            comm.sudo("mv #{path}.new #{path}")
            comm.sudo("rm #{tmp}")
          end
        end

        def environment_sed_script
          <<-SED.gsub(/^\s+/, '')
            /^HTTP_PROXY=/ d
            /^HTTPS_PROXY=/ d
            /^FTP_PROXY=/ d
            /^NO_PROXY=/ d
            /^http_proxy=/ d
            /^https_proxy=/ d
            /^ftp_proxy=/ d
            /^no_proxy=/ d
          SED
        end

        def environment_config
          <<-CONFIG.gsub(/^\s+/, '')
            HTTP_PROXY=#{config.http || ''}
            HTTPS_PROXY=#{config.https || ''}
            FTP_PROXY=#{config.ftp || ''}
            NO_PROXY=#{config.no_proxy || ''}
            http_proxy=#{config.http || ''}
            https_proxy=#{config.https || ''}
            ftp_proxy=#{config.ftp || ''}
            no_proxy=#{config.no_proxy || ''}
          CONFIG
        end
      end
    end
  end
end
