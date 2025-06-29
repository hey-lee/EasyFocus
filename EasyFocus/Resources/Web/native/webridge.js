var __defProp = Object.defineProperty;
var __export = function(target, all) {
    for(var name in all)__defProp(target, name, {
        get: all[name],
        enumerable: true
    });
};
// src/fns/index.ts
var fns_exports = {};
__export(fns_exports, {
    emit: function() {
        return emit;
    },
    invoke: function() {
        return invoke;
    }
});
var invoke = function(action) {
    var params = arguments.length > 1 && arguments[1] !== void 0 ? arguments[1] : {};
    try {
        var webkit = window.webkit;
        if (webkit && webkit.messageHandlers.nativeApp) {
            webkit.messageHandlers.nativeApp.postMessage(JSON.stringify({
                action: action,
                params: params
            }));
        }
    } catch (error) {
        console.log("invoke action ".concat(action, " error:"), error);
    }
};
var emit = function(key, data) {
    try {
        var event = new CustomEvent(key, {
            detail: data
        });
        window.dispatchEvent(event);
    } catch (error) {
        invoke("error", {
            message: error.message
        });
    }
};
// src/index.ts
window.bridge = fns_exports;
export { emit, invoke };
//# sourceMappingURL=webridge.js.map
