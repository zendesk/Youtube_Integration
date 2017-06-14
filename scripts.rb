account = "support".to_account

# Create registered integration service (app install)
Channels::AnyChannel::RegisteredIntegrationService.destroy_all
ris = Channels::AnyChannel::RegisteredIntegrationService.create_from_manifest_url!('https://6799e2b8.ngrok.io/manifest', account.id)

# Create integration service instance (ui account creation)
Channels::AnyChannel::IntegrationServiceInstance.destroy_all
isi = Channels::AnyChannel::IntegrationServiceInstance.create!(registered_integration_service_id: ris.id, name: 'test', metadata: "x", state: "", account: account)

# Poll (replicate job polling) This will happen every 2 mins in staging and production anyway
monitor = Channels::Monitor::AnyChannel::AccountMonitor.new(account)
monitor.poll!

Channels::IncomingConversion.all.each { |ic| ic.run_job }


# curl --data '' https://6799e2b8.ngrok.io/admin_ui <-- to test a POST request
