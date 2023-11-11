"use strict";

var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

var AffiliateIdsHandler = function () {
  function AffiliateIdsHandler(chrome) {
    var _this = this;

    _classCallCheck(this, AffiliateIdsHandler);

    this._chrome = chrome;
    this._affiliateIdsCounts = {};
    this._lastAffiliateId = '';
    this._lastAffiliateIdTimestamp = 0;
    this._affiliateIds = [];

    this._chrome.runtime.onInstalled.addListener(function (details) {
      if (details.reason == "install") {
        _this.setupDatabase();
      }
      if (details.reason == "update") {
        _this.convertDatabase();
      }
    });
    this.loadDatabase();
    this._chrome.storage.onChanged.addListener(function (changes, namespace) {
      _this.loadDatabase();
    });
  }

  _createClass(AffiliateIdsHandler, [{
    key: "convertDatabase",
    value: function convertDatabase() {
      var _this2 = this;

      this._chrome.storage.sync.get('runtime', function (data) {
        if (data.runtime) {
          /**
           * if we have the old database structure present, we will put every affiliate id, into every country
           */
          if (data.runtime.affiliateIds) {
            for (var countryCode in AffiliateIdChecker.associatePrograms) {
              data.runtime[countryCode] = {
                ids: [],
                lastAffiliateId: false,
                lastAffiliateIdTimestamp: 0
              };
            }
            for (var id in data.runtime.affiliateIds) {
              for (var _countryCode in AffiliateIdChecker.associatePrograms) {
                data.runtime[_countryCode].ids.push(data.runtime.affiliateIds[id]);
              }
            }
            delete data.runtime.affiliateIds;
            delete data.runtime.environment;
            _this2._chrome.storage.sync.set(data);
          }
        }
      });
    }
  }, {
    key: "setupDatabase",
    value: function setupDatabase() {
      var data = {
        runtime: {
          config: {
            prevent: false
          },
          de: {
            ids: [{
              name: "Gumba",
              id: "gumba-21"
            }],
            lastAffiliateId: false,
            lastAffiliateIdTimestamp: 0
          },
          uk: {
            ids: [],
            lastAffiliateId: false,
            lastAffiliateIdTimestamp: 0
          },
          us: {
            ids: [{
              name: "Gumba",
              id: "gumba0b-20"
            }],
            lastAffiliateId: false,
            lastAffiliateIdTimestamp: 0
          },
          fr: {
            ids: [],
            lastAffiliateId: false,
            lastAffiliateIdTimestamp: 0
          },
          jp: {
            ids: [],
            lastAffiliateId: false,
            lastAffiliateIdTimestamp: 0
          },
          ca: {
            ids: [],
            lastAffiliateId: false,
            lastAffiliateIdTimestamp: 0
          },
          cn: {
            ids: [],
            lastAffiliateId: false,
            lastAffiliateIdTimestamp: 0
          },
          it: {
            ids: [],
            lastAffiliateId: false,
            lastAffiliateIdTimestamp: 0
          },
          es: {
            ids: [],
            lastAffiliateId: false,
            lastAffiliateIdTimestamp: 0
          },
          in: {
            ids: [],
            lastAffiliateId: false,
            lastAffiliateIdTimestamp: 0
          },
          br: {
            ids: [],
            lastAffiliateId: false,
            lastAffiliateIdTimestamp: 0
          }
        }
      };
      this._chrome.storage.sync.set(data);
      return data;
    }
  }, {
    key: "loadDatabase",
    value: function loadDatabase() {
      var _this3 = this;

      this._chrome.storage.sync.get('runtime', function (data) {
        if (!data || Object.keys(data).length === 0) {
          data = _this3.setupDatabase();
        }
        _this3._runtime = data.runtime;

        /**
         * If the Database-Change that coused the Reload has deleted an 
         * Affiliate-Id that was set as last Affiliate-Id
         * we have to clear the last Affiliate-Id setting
         */
        var changed = false;
        for (var countryCode in _this3._runtime) {
          if (_this3._runtime[countryCode].lastAffiliateId) {
            var found = false;
            for (var id in _this3._runtime[countryCode].ids) {
              if (_this3._runtime[countryCode].lastAffiliateId == _this3._runtime[countryCode].ids[id].id) found = true;
            }
            if (!found) {
              changed = true;
              _this3._runtime[countryCode].lastAffiliateId = false;
              _this3._runtime[countryCode].lastAffiliateIdTimestamp = 0;
            }
          }
        }
        if (changed) _this3._saveState();
      });
    }
  }, {
    key: "getAffiliateIdsCount",
    value: function getAffiliateIdsCount(countryCode) {
      return this._runtime[countryCode].ids.length;
    }
  }, {
    key: "getAffiliateId",
    value: function getAffiliateId(countryCode) {
      /**
       * if lastAffiliateId is set we iterate to it and choose the next id
       */
      if (this._runtime[countryCode].lastAffiliateId) {
        var found = false;
        var currentTime = new Date().getTime();

        /**
         * Just return a new affiliate-id for every 30 minutes.
         */
        if (currentTime - this._runtime[countryCode].lastAffiliateIdTimestamp < 1800000) return this._runtime[countryCode].lastAffiliateId;

        for (var i = 0; i < this._runtime[countryCode].ids.length; i++) {
          if (found === true) {
            this._runtime[countryCode].lastAffiliateId = this._runtime[countryCode].ids[i].id;
            this._runtime[countryCode].lastAffiliateIdTimestamp = new Date().getTime();
            this._saveState();
            chrome.browserAction.setBadgeText({ "text": this._runtime[countryCode].ids[i].name });
            return this._runtime[countryCode].lastAffiliateId;
          }
          /**
           * found means next iteration is the id we want
           */
          if (this._runtime[countryCode].lastAffiliateId == this._runtime[countryCode].ids[i].id) {
            found = true;
          }

          /**
           * if we looped over the whole array, we restart at the beginning
           */
          if (i >= this._runtime[countryCode].ids.length - 1) {
            i = -1;
          }
        }
      } else {
        this._runtime[countryCode].lastAffiliateId = this._runtime[countryCode].ids[0].id;
        this._runtime[countryCode].lastAffiliateIdTimestamp = new Date().getTime();
        this._saveState();
        chrome.browserAction.setBadgeText({ "text": this._runtime[countryCode].ids[0].name });
        return this._runtime[countryCode].lastAffiliateId;
      }
    }
  }, {
    key: "isConfiguredId",
    value: function isConfiguredId(affiliateId, countryCode) {
      for (var i = 0; i < this._runtime[countryCode].ids.length; i++) {
        if (this._runtime[countryCode].ids[i].id == affiliateId) return true;
      }return false;
    }
  }, {
    key: "isOverwritePreventionOn",
    value: function isOverwritePreventionOn() {
      if (this._runtime.config.prevent) {
        return true;
      }
      return false;
    }
  }, {
    key: "_saveState",
    value: function _saveState() {
      this._chrome.storage.sync.set({ 'runtime': this._runtime });
    }
  }]);

  return AffiliateIdsHandler;
}();

var afh = new AffiliateIdsHandler(chrome);

var AffiliateIdChecker = function () {
  function AffiliateIdChecker(chrome) {
    var _this4 = this;

    _classCallCheck(this, AffiliateIdChecker);

    this._chrome = chrome;
    this._affiliateIdsHandler = new AffiliateIdsHandler(this._chrome);

    var _loop = function _loop(countryCode) {
      _this4._chrome.webRequest.onBeforeRequest.addListener(function (details) {
        return _this4.checkForAmazonAffiliate(details, countryCode);
      }, AffiliateIdChecker.associatePrograms[countryCode].filters, // only run for requests to the following urls
      ['blocking'] // blocking permission necessary in order to perform the redirect
      );
    };

    for (var countryCode in AffiliateIdChecker.associatePrograms) {
      _loop(countryCode);
    }
  }

  _createClass(AffiliateIdChecker, [{
    key: "checkForAmazonAffiliate",
    value: function checkForAmazonAffiliate(details, countryCode) {
      var url_parts = void 0;

      /**
       * only run, if at least 1 affiliate id is set
       **/
      if (this._affiliateIdsHandler.getAffiliateIdsCount(countryCode) < 1) return {};

      /**
       * Only run on Navigation-Requests
       */
      if (details.url.search("ap/signin") != -1 || details.url.search("ap/widget") != -1 || details.url.search("ref=nav_cs") != -1 || details.url.search("ref=nav_logo") != -1) {
        return {};
      }

      if (details.frameId == 0) {
        if (details.url.search(/\?/) === -1) {
          /**
           * If the url has no parameters just add the id at the end.
           */
          return {
            redirectUrl: details.url + '?tag=' + this._affiliateIdsHandler.getAffiliateId(countryCode)
          };
        }

        if (details.url.search(/\?tag/) == -1 && details.url.search(/\&tag/) == -1) {
          /**
           * If there is no tag parameter set. 
           */
          return {
            redirectUrl: details.url + '&tag=' + this._affiliateIdsHandler.getAffiliateId(countryCode)
          };
        }

        url_parts = details.url.split('?');
        if (url_parts.length > 1) {
          var parameter_parts = url_parts[1].split('&');
          for (var i = 0; i < parameter_parts.length; i++) {
            if (!this._affiliateIdsHandler.isOverwritePreventionOn() && parameter_parts[i].substring(0, 4) == 'tag=' && !this._affiliateIdsHandler.isConfiguredId(parameter_parts[i].substring(4), countryCode)) {
              return {
                redirectUrl: details.url.replace(parameter_parts[i], 'tag=' + this._affiliateIdsHandler.getAffiliateId(countryCode))
              };
            }
          }
        }
      }
    }
  }]);

  return AffiliateIdChecker;
}();

AffiliateIdChecker.associatePrograms = {
  de: {
    name: "www.amazon.de",
    url: "https://www.amazon.de",
    filters: {
      urls: ["*://www.amazon.de/*"],
      types: ["main_frame"]
    }
  },
  uk: {
    name: "www.amazon.co.uk",
    url: "https://www.amazon.co.uk",
    filters: {
      urls: ["*://www.amazon.co.uk/*"],
      types: ["main_frame"]
    }
  },
  us: {
    name: "www.amazon.com",
    url: "https://www.amazon.com",
    filters: {
      urls: ["*://www.amazon.com/*"],
      types: ["main_frame"]
    }
  },
  fr: {
    name: "www.amazon.fr",
    url: "https://www.amazon.fr",
    filters: {
      urls: ["*://www.amazon.fr/*"],
      types: ["main_frame"]
    }
  },
  jp: {
    "name": "www.amazon.co.jp",
    "url": "https://www.amazon.co.jp",
    filters: {
      urls: ["*://www.amazon.co.jp/*"],
      types: ["main_frame"]
    }
  },
  ca: {
    name: "www.amazon.ca",
    url: "https://www.amazon.ca",
    filters: {
      urls: ["*://www.amazon.ca/*"],
      types: ["main_frame"]
    }
  },
  cn: {
    name: "www.amazon.cn",
    url: "https://www.amazon.cn",
    filters: {
      urls: ["*://www.amazon.cn/*"],
      types: ["main_frame"]
    }
  },
  it: {
    name: "www.amazon.it",
    url: "https://www.amazon.it",
    filters: {
      urls: ["*://www.amazon.it/*"],
      types: ["main_frame"]
    }
  },
  es: {
    name: "www.amazon.es",
    url: "https://www.amazon.es",
    filters: {
      urls: ["*://www.amazon.es/*"],
      types: ["main_frame"]
    }
  },
  in: {
    name: "www.amazon.in",
    url: "https://www.amazon.in",
    filters: {
      urls: ["*://www.amazon.in/*"],
      types: ["main_frame"]
    }
  },
  br: {
    name: "www.amazon.com.br",
    url: "https://www.amazon.com.br",
    filters: {
      urls: ["*://www.amazon.com.br/*"],
      types: ["main_frame"]
    }
  }
};


var plugin = new AffiliateIdChecker(chrome);