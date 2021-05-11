(function (global, factory) {
    typeof exports === 'object' && typeof module !== 'undefined' ? factory(exports) :
        typeof define === 'function' && define.amd ? define(['exports'], factory) :
            (global = typeof globalThis !== 'undefined' ? globalThis : global || self, factory(global.FronteggApp = {}));
}(this, (function (exports) { 'use strict';

    /*! *****************************************************************************
    Copyright (c) Microsoft Corporation.

    Permission to use, copy, modify, and/or distribute this software for any
    purpose with or without fee is hereby granted.

    THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
    REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
    AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
    INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
    LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
    OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
    PERFORMANCE OF THIS SOFTWARE.
    ***************************************************************************** */

    var __assign = function() {
        __assign = Object.assign || function __assign(t) {
            for (var s, i = 1, n = arguments.length; i < n; i++) {
                s = arguments[i];
                for (var p in s) if (Object.prototype.hasOwnProperty.call(s, p)) t[p] = s[p];
            }
            return t;
        };
        return __assign.apply(this, arguments);
    };

    function __rest(s, e) {
        var t = {};
        for (var p in s) if (Object.prototype.hasOwnProperty.call(s, p) && e.indexOf(p) < 0)
            t[p] = s[p];
        if (s != null && typeof Object.getOwnPropertySymbols === "function")
            for (var i = 0, p = Object.getOwnPropertySymbols(s); i < p.length; i++) {
                if (e.indexOf(p[i]) < 0 && Object.prototype.propertyIsEnumerable.call(s, p[i]))
                    t[p[i]] = s[p[i]];
            }
        return t;
    }

    function __awaiter(thisArg, _arguments, P, generator) {
        function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
        return new (P || (P = Promise))(function (resolve, reject) {
            function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
            function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
            function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
            step((generator = generator.apply(thisArg, _arguments || [])).next());
        });
    }

    function __generator(thisArg, body) {
        var _ = { label: 0, sent: function() { if (t[0] & 1) throw t[1]; return t[1]; }, trys: [], ops: [] }, f, y, t, g;
        return g = { next: verb(0), "throw": verb(1), "return": verb(2) }, typeof Symbol === "function" && (g[Symbol.iterator] = function() { return this; }), g;
        function verb(n) { return function (v) { return step([n, v]); }; }
        function step(op) {
            if (f) throw new TypeError("Generator is already executing.");
            while (_) try {
                if (f = 1, y && (t = op[0] & 2 ? y["return"] : op[0] ? y["throw"] || ((t = y["return"]) && t.call(y), 0) : y.next) && !(t = t.call(y, op[1])).done) return t;
                if (y = 0, t) op = [op[0] & 2, t.value];
                switch (op[0]) {
                    case 0: case 1: t = op; break;
                    case 4: _.label++; return { value: op[1], done: false };
                    case 5: _.label++; y = op[1]; op = [0]; continue;
                    case 7: op = _.ops.pop(); _.trys.pop(); continue;
                    default:
                        if (!(t = _.trys, t = t.length > 0 && t[t.length - 1]) && (op[0] === 6 || op[0] === 2)) { _ = 0; continue; }
                        if (op[0] === 3 && (!t || (op[1] > t[0] && op[1] < t[3]))) { _.label = op[1]; break; }
                        if (op[0] === 6 && _.label < t[1]) { _.label = t[1]; t = op; break; }
                        if (t && _.label < t[2]) { _.label = t[2]; _.ops.push(op); break; }
                        if (t[2]) _.ops.pop();
                        _.trys.pop(); continue;
                }
                op = body.call(thisArg, _);
            } catch (e) { op = [6, e]; y = 0; } finally { f = t = 0; }
            if (op[0] & 5) throw op[1]; return { value: op[0] ? op[1] : void 0, done: true };
        }
    }

    class Logger {
        constructor(disabled = false, logger) {
            var _a, _b, _c;
            this.disabled = disabled;
            this.logger = logger;
            this.log = (l, prefix, color) => {
                if (this.disabled) {
                    return () => { };
                }
                if (typeof this.logger === 'function') {
                    return this.logger;
                }
                // tslint:disable-next-line:no-console
                if (console.log.bind === undefined) {
                    // @ts-ignore
                    return Function.prototype.bind.call(console[l], console, prefix || '', color || '-');
                }
                else {
                    // @ts-ignore
                    return console[l].bind(console, prefix || '', color || '-');
                }
            };
            this.info = (_a = this.log) === null || _a === void 0 ? void 0 : _a.call(this, 'log', '%c[AdminBox]', 'background:#e8e8e8;');
            this.warn = (_b = this.log) === null || _b === void 0 ? void 0 : _b.call(this, 'warn', '[AdminBox]');
            this.error = (_c = this.log) === null || _c === void 0 ? void 0 : _c.call(this, 'error', '[AdminBox]');
        }
    }

    var __awaiter$1 = (undefined && undefined.__awaiter) || function (thisArg, _arguments, P, generator) {
        function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
        return new (P || (P = Promise))(function (resolve, reject) {
            function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
            function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
            function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
            step((generator = generator.apply(thisArg, _arguments || [])).next());
        });
    };
    function getOrCreateHtmlElementInside(id, container) {
        let el = container.querySelector(`#${id}`);
        if (!el) {
            el = document.createElement('div');
            el.setAttribute('id', id);
            container.appendChild(el);
        }
        return el;
    }
    function getVersionMetadata(logger, cdn, _version) {
        return __awaiter$1(this, void 0, void 0, function* () {
            logger.info(`Retrieving version from cdn: ${cdn} version: ${_version}`);
            let version = _version;
            if (version !== 'latest' && version !== 'stable' && version !== 'next') {
                version = `${_version}/config`;
            }
            const res = yield fetch(`${cdn}/${version}.json`, { cache: 'no-cache' });
            return res.json();
        });
    }

    var __awaiter$2 = (undefined && undefined.__awaiter) || function (thisArg, _arguments, P, generator) {
        function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
        return new (P || (P = Promise))(function (resolve, reject) {
            function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
            function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
            function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
            step((generator = generator.apply(thisArg, _arguments || [])).next());
        });
    };
    const CONTAINER_ID_PREFIX = 'frontegg-host';
    const CONTENT_ID_PREFIX = 'frontegg-content';
    class Injector {
        constructor(name, options) {
            this.js = [];
            this.css = [];
            this.isOpen = false;
            this.loaded = false;
            this.name = 'default';
            this.cdn = 'https://fronteggdeveustorage.blob.core.windows.net/admin-box';
            this.version = 'latest';
            this.mount = () => { this.logger.error('App not loaded yet'); };
            this.unmount = () => { this.logger.error('App not loaded yet'); };
            this.logger = new Logger(true);
            this.logger.info('Create shadow dom element');
            this.hostEl = getOrCreateHtmlElementInside(`${CONTAINER_ID_PREFIX}-${name}`, document.body);
            this.shadowEl = this.hostEl.attachShadow({
                mode: 'open',
                delegatesFocus: true,
            });
            this.rootEl = getOrCreateHtmlElementInside(CONTENT_ID_PREFIX, this.shadowEl);
            this.name = name;
            this.options = options;
            this.open = this.open.bind(this);
            this.close = this.close.bind(this);
            this.destroy = this.destroy.bind(this);
            this.injectJavascript = this.injectJavascript.bind(this);
            this.injectCss = this.injectCss.bind(this);
        }
        static init(options, name = 'default') {
            var _a;
            return __awaiter$2(this, void 0, void 0, function* () {
                Object.assign(window, { FronteggInjector: Injector });
                const instance = new Injector(name, options);
                const { logger } = instance;
                Injector._apps[name] = instance;
                logger.info('Initializing Injector instance');
                instance.cdn = (_a = options.cdn) !== null && _a !== void 0 ? _a : instance.cdn;
                instance.cdn = instance.cdn.endsWith('/') ? instance.cdn.substring(0, instance.cdn.length - 1) : instance.cdn;
                logger.info('Retrieving version metadata');
                const metadata = yield getVersionMetadata(logger, instance.cdn, options.version);
                instance.version = metadata.version;
                instance.js = metadata.js;
                instance.css = metadata.css;
                logger.info(`Injector instance initialized successfully`, Object.assign({ name, cdn: instance.version }, metadata));
                instance.loaded = true;
                logger.info('Loading entrypoint files');
                yield instance.loadEntrypoints();
                logger.info('Entrypoint files loaded successfully');
            });
        }
        static getInstance(name = 'default') {
            const instance = Injector._apps[name];
            if (!instance) {
                throw Error(`injector instance not found for name: ${name}.\nInject.init(options${name === 'default' ? '' : `, '${name}'`}) must be called`);
            }
            return instance;
        }
        open() {
            if (!this.loaded) {
                throw Error(`Injected app [${this.name}] not loaded yet!`);
            }
            this.mount(this.rootEl, this.options);
            this.isOpen = true;
        }
        close() {
            if (!this.loaded) {
                throw Error(`Injected app [${this.name}] not loaded yet!`);
            }
            this.unmount(this.rootEl);
            this.isOpen = false;
        }
        destroy() {
            delete Injector._apps[this.name];
            this.hostEl.remove();
            this.logger.info(`${this.name} destroyed`);
        }
        loadEntrypoints() {
            return __awaiter$2(this, void 0, void 0, function* () {
                return Promise.all([
                    ...this.js.map((file) => this.injectJavascript(`${this.cdn}/${this.version}/js/${file}`)),
                    ...this.css.map((file) => this.injectCss(`${this.cdn}/${this.version}/css/${file}`)),
                ]);
            });
        }
        injectJavascript(url) {
            return (() => __awaiter$2(this, void 0, void 0, function* () {
                const logger = this.logger;
                if (typeof url !== 'string') {
                    url = url.src;
                }
                logger.info('Loading JS file from ', url);
                const res = yield fetch(url, { method: 'GET', cache: 'default' });
                let contentScript = yield res.text();
                const bundleScript = document.createElement('script');
                bundleScript.setAttribute('charset', 'utf-8');
                bundleScript.setAttribute('type', 'text/javascript');
                if (contentScript.indexOf('FRONTEGG_INJECTOR_CDN_HOST')) {
                    contentScript = contentScript.replace('/FRONTEGG_INJECTOR_CDN_HOST', this.cdn);
                    contentScript = `(()=> { const fronteggInjector = FronteggInjector.getInstance('${this.name}');
          ${contentScript}
          })();`;
                }
                bundleScript.innerHTML = contentScript;
                this.shadowEl.appendChild(bundleScript);
                logger.info('JS loaded successfully', url);
            }))();
        }
        injectCss(url) {
            return new Promise((resolve) => {
                const logger = this.logger;
                if (typeof url === 'string') {
                    logger.info('Loading CSS file from ', url);
                    const bundleCss = document.createElement('link');
                    bundleCss.href = url;
                    bundleCss.rel = 'stylesheet';
                    bundleCss.type = 'text/css';
                    this.shadowEl.prepend(bundleCss);
                    bundleCss.onload = () => {
                        logger.info('CSS loaded successfully', url);
                        resolve();
                    };
                }
                else {
                    logger.info('Loading lazy CSS file from ', url.href);
                    this.shadowEl.insertBefore(url, this.rootEl);
                    resolve();
                }
            });
        }
    }
    Injector._apps = {};

    var FronteggApp = /** @class */ (function () {
        function FronteggApp(name, _a) {
            var _this = this;
            var store = _a.store, options = __rest(_a, ["store"]);
            this.loaded = false;
            this.loadSubscribers = [];
            this.storeSubscribers = [];
            this.onLoad = function (callback) {
                _this.loadSubscribers.push(callback);
                if (_this.loaded) {
                    callback();
                }
            };
            this.onStoreChanged = function (callback) {
                _this.storeSubscribers.push(callback);
            };
            this.name = name;
            this.options = options;
            this.store = store;
            this.initInjectors();
        }
        FronteggApp.prototype.initInjectors = function () {
            var _a, _b, _c, _d, _e, _f;
            return __awaiter(this, void 0, void 0, function () {
                var adminPortalName, loginBoxName, serverMetadata, response, data, e_1, waitForLoadingModules;
                var _this = this;
                return __generator(this, function (_g) {
                    switch (_g.label) {
                        case 0:
                            adminPortalName = this.name + "_admin-portal";
                            loginBoxName = this.name + "_login-box";
                            try {
                                document.body.classList.add('frontegg-loading');
                            }
                            catch (e) {
                            }
                            serverMetadata = {};
                            if (!this.options.metadata) return [3 /*break*/, 1];
                            serverMetadata = (_a = this.options.metadata) !== null && _a !== void 0 ? _a : {};
                            return [3 /*break*/, 5];
                        case 1:
                            _g.trys.push([1, 4, , 5]);
                            return [4 /*yield*/, fetch(this.options.contextOptions.baseUrl + "/frontegg/metadata?entityName=adminBox")];
                        case 2:
                            response = _g.sent();
                            return [4 /*yield*/, response.json()];
                        case 3:
                            data = _g.sent();
                            serverMetadata = (_d = (_c = (_b = data === null || data === void 0 ? void 0 : data.rows) === null || _b === void 0 ? void 0 : _b[0]) === null || _c === void 0 ? void 0 : _c.configuration) !== null && _d !== void 0 ? _d : {};
                            return [3 /*break*/, 5];
                        case 4:
                            e_1 = _g.sent();
                            console.error('failed to get admin portal metadata', e_1);
                            return [3 /*break*/, 5];
                        case 5:
                            Injector.init(__assign(__assign({ version: 'latest' }, this.options), { cdn: ((_e = this.options.cdn) !== null && _e !== void 0 ? _e : 'https://assets.frontegg.com') + "/admin-box", metadata: serverMetadata }), adminPortalName);
                            if (!this.options.previewMode || this.options.customLoginBox) {
                                Injector.init(__assign(__assign({ version: 'latest' }, this.options), { cdn: ((_f = this.options.cdn) !== null && _f !== void 0 ? _f : 'https://assets.frontegg.com') + "/login-box", metadata: serverMetadata }), loginBoxName);
                            }
                            this.adminPortal = Injector.getInstance(adminPortalName);
                            if (!this.options.previewMode || this.options.customLoginBox) {
                                this.loginBox = Injector.getInstance(loginBoxName);
                            }
                            waitForLoadingModules = setInterval(function () {
                                var _a, _b, _c;
                                if (((_a = _this.adminPortal) === null || _a === void 0 ? void 0 : _a.loaded)
                                    && (_this.options.previewMode || ((_b = _this.loginBox) === null || _b === void 0 ? void 0 : _b.loaded))
                                    && _this.store) {
                                    clearInterval(waitForLoadingModules);
                                    _this.loaded = true;
                                    _this.loadSubscribers.forEach(function (c) { return c(); });
                                    (_c = _this.store) === null || _c === void 0 ? void 0 : _c.subscribe(function () {
                                        _this.storeSubscribers.forEach(function (listener) {
                                            var _a, _b;
                                            var state = (_b = (_a = _this.store) === null || _a === void 0 ? void 0 : _a.getState) === null || _b === void 0 ? void 0 : _b.call(_a);
                                            state && listener(state);
                                        });
                                    });
                                }
                            }, 50);
                            // @ts-ignore
                            this.adminPortal.app = this;
                            if (!this.options.previewMode || this.options.customLoginBox) {
                                // @ts-ignore
                                this.loginBox.app = this;
                            }
                            return [2 /*return*/];
                    }
                });
            });
        };
        FronteggApp.getInstance = function (name) {
            var instance = FronteggApp._apps[name];
            if (!instance) {
                throw Error("Frontegg instance not found for name: " + name + ".\nFrontegg.initialize(options" + (name === 'default' ? '' : ", '" + name + "'") + ") must be called");
            }
            return instance;
        };
        FronteggApp.setConfig = function (config, name) {
            if (name === void 0) { name = 'default'; }
            var instance = FronteggApp._apps[name];
            if (instance) {
                console.warn("Frontegg instance already initialized for name: " + name);
            }
            else {
                instance = new FronteggApp(name, config);
                FronteggApp._apps[name] = instance;
            }
            return instance;
        };
        FronteggApp.getConfig = function (name) {
            if (name === void 0) { name = 'default'; }
            return FronteggApp.getInstance(name);
        };
        FronteggApp.prototype.mountAdminPortal = function () {
            var _a;
            (_a = this.adminPortal) === null || _a === void 0 ? void 0 : _a.open();
        };
        FronteggApp.prototype.unmountAdminPortal = function () {
            var _a;
            (_a = this.adminPortal) === null || _a === void 0 ? void 0 : _a.close();
        };
        FronteggApp.prototype.mountLoginBox = function () {
            var _a;
            (_a = this.loginBox) === null || _a === void 0 ? void 0 : _a.open();
        };
        FronteggApp.prototype.unmountLoginBox = function () {
            var _a;
            (_a = this.loginBox) === null || _a === void 0 ? void 0 : _a.close();
        };
        FronteggApp._apps = {};
        return FronteggApp;
    }());
    var initialize = function (config, name) {
        if (name === void 0) { name = 'default'; }
        return FronteggApp.setConfig(config, name);
    };
    var AdminPortal = {
        show: function (name) {
            if (name === void 0) { name = 'default'; }
            FronteggApp.getConfig(name).mountAdminPortal();
        },
        hide: function (name) {
            if (name === void 0) { name = 'default'; }
            FronteggApp.getConfig(name).unmountAdminPortal();
        },
    };
    var LoginBox = {
        show: function (name) {
            if (name === void 0) { name = 'default'; }
            FronteggApp.getConfig(name).mountLoginBox();
        },
        hide: function (name) {
            if (name === void 0) { name = 'default'; }
            FronteggApp.getConfig(name).unmountLoginBox();
        },
    };
    if (typeof window != 'undefined') {
        Object.assign(window, {
            FronteggApp: FronteggApp,
            AdminPortal: AdminPortal,
            LoginBox: LoginBox,
            Frontegg: {
                initialize: initialize,
            },
        });
    }

    exports.AdminPortal = AdminPortal;
    exports.LoginBox = LoginBox;
    exports.initialize = initialize;

    Object.defineProperty(exports, '__esModule', { value: true });

})));
