function _array_like_to_array(arr, len) {
    if (len == null || len > arr.length) len = arr.length;
    for(var i = 0, arr2 = new Array(len); i < len; i++)arr2[i] = arr[i];
    return arr2;
}
function _array_with_holes(arr) {
    if (Array.isArray(arr)) return arr;
}
function _iterable_to_array_limit(arr, i) {
    var _i = arr == null ? null : typeof Symbol !== "undefined" && arr[Symbol.iterator] || arr["@@iterator"];
    if (_i == null) return;
    var _arr = [];
    var _n = true;
    var _d = false;
    var _s, _e;
    try {
        for(_i = _i.call(arr); !(_n = (_s = _i.next()).done); _n = true){
            _arr.push(_s.value);
            if (i && _arr.length === i) break;
        }
    } catch (err) {
        _d = true;
        _e = err;
    } finally{
        try {
            if (!_n && _i["return"] != null) _i["return"]();
        } finally{
            if (_d) throw _e;
        }
    }
    return _arr;
}
function _non_iterable_rest() {
    throw new TypeError("Invalid attempt to destructure non-iterable instance.\\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method.");
}
function _sliced_to_array(arr, i) {
    return _array_with_holes(arr) || _iterable_to_array_limit(arr, i) || _unsupported_iterable_to_array(arr, i) || _non_iterable_rest();
}
function _unsupported_iterable_to_array(o, minLen) {
    if (!o) return;
    if (typeof o === "string") return _array_like_to_array(o, minLen);
    var n = Object.prototype.toString.call(o).slice(8, -1);
    if (n === "Object" && o.constructor) n = o.constructor.name;
    if (n === "Map" || n === "Set") return Array.from(n);
    if (n === "Arguments" || /^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(n)) return _array_like_to_array(o, minLen);
}
var __defProp = Object.defineProperty;
var __export = function(target, all) {
    for(var name in all)__defProp(target, name, {
        get: all[name],
        enumerable: true
    });
};
// src/bridge/index.ts
var bridge_exports = {};
__export(bridge_exports, {
    callScheme: function() {
        return callScheme;
    },
    emit: function() {
        return emit;
    },
    invoke: function() {
        return invoke;
    }
});
// src/fns/index.ts
var stringify = function() {
    var params = arguments.length > 0 && arguments[0] !== void 0 ? arguments[0] : {};
    var queryString = Object.entries(params).map(function(param) {
        var _param = _sliced_to_array(param, 2), key = _param[0], value = _param[1];
        return "".concat(encodeURIComponent(key), "=").concat(encodeURIComponent(value));
    }).join("&");
    return Object.keys(params).length ? "?".concat(queryString) : queryString;
};
// src/bridge/index.ts
var callScheme = function(action) {
    var params = arguments.length > 1 && arguments[1] !== void 0 ? arguments[1] : {};
    try {
        var url = "foca://".concat(action).concat(stringify(params));
        window.location.href = url;
    } catch (error) {
        console.log("callScheme error:", error);
    }
};
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
window.bridge = bridge_exports;
//# sourceMappingURL=webridge.js.map
