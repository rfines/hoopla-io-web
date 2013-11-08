c = require('config');
exports.config = {
  app_name : ['hoopla-io-web'],
  license_key : c.monitoring.newrelic.licenseKey,
  logging : {
    /**
     * Level at which to log. 'trace' is most useful to New Relic when diagnosing
     * issues with the agent, 'info' and higher will impose the least overhead on
     * production applications.
     */
    level : 'info'
  }
};