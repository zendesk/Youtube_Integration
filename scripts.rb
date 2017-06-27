account = "support".to_account

# Create registered integration service (app install)
Channels::AnyChannel::RegisteredIntegrationService.destroy_all
ris = Channels::AnyChannel::RegisteredIntegrationService.create_from_manifest_url!('https://0bba4895.ngrok.io/manifest', account.id)

# Create integration service instance (ui account creation)
Channels::AnyChannel::IntegrationServiceInstance.destroy_all
isi = Channels::AnyChannel::IntegrationServiceInstance.create!(registered_integration_service_id: ris.id, name: 'test', metadata: "x", state: "", account: account)

# Poll (replicate job polling) This will happen every 2 mins in staging and production anyway
monitor = Channels::Monitor::AnyChannel::AccountMonitor.new(account)
monitor.poll!

Channels::IncomingConversion.all.each { |ic| ic.run_job }


# Get registered integration services
curl -XGET -u <username>:<password> https://<subdomain>.zendesk.com/api/v2/channels/registered_integration_services.json |python -m json.tool

# Get integration service instances (accounts)
curl -XGET -u <username>:<password> https://<subdomain>.zendesk.com/api/v2/channels/registered_integration_services/114093956553/integration_service_instances.json |python -m json.tool

# Post to the pull and convert to not have to wait 2 mins for polling
curl -XPOST -u thsu@zendesk.com:Th070296! https://z3ntim.zendesk.com/api/v2/channels/registered_integration_services/114093956553/integration_service_instances/114093956433/pull_and_convert
