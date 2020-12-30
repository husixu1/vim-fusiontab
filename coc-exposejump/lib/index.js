(function(e, a) { for(var i in a) e[i] = a[i]; if(a.__esModule) Object.defineProperty(e, "__esModule", { value: true }); }(exports,
/******/ (() => { // webpackBootstrap
/******/ 	"use strict";
/******/ 	var __webpack_modules__ = ([
/* 0 */
/***/ ((__unused_webpack_module, exports, __webpack_require__) => {


Object.defineProperty(exports, "__esModule", ({ value: true }));
exports.activate = void 0;
const coc_nvim_1 = __webpack_require__(1);
async function activate(context) {
    // workspace.showMessage(`coc-exposejump works!`);
    const config = coc_nvim_1.workspace.getConfiguration('coc-exposejump');
    const isEnable = config.get('enable', true);
    if (!isEnable) {
        return;
    }
    context.subscriptions.push(coc_nvim_1.commands.registerCommand('coc-exposejump.info', async (direction) => {
        //console.log((<any>snippetManager.getSession(workspace.bufnr)?.snippet)?.tmSnippet.placeholderInfo.all);
        // console.log((<any>snippetManager.getSession(workspace.bufnr)?.snippet)?.tmSnippet);
        const session = coc_nvim_1.snippetManager.getSession(coc_nvim_1.workspace.bufnr);
        const cur_tabstop = session === null || session === void 0 ? void 0 : session.placeholder;
        const target_tabstop = direction == 'forward'
            ? session === null || session === void 0 ? void 0 : session.snippet.getNextPlaceholder(cur_tabstop.index) : direction == 'backward'
            ? session === null || session === void 0 ? void 0 : session.snippet.getPrevPlaceholder(cur_tabstop.index) : null;
        const target_range = session === null || session === void 0 ? void 0 : session.snippet.range;
        return target_tabstop
            ? {
                cur: {
                    ls: cur_tabstop.range.start.line,
                    le: cur_tabstop.range.end.line,
                    cs: cur_tabstop.range.start.character,
                    ce: cur_tabstop.range.end.character,
                },
                tgt: {
                    ls: target_tabstop.range.start.line,
                    le: target_tabstop.range.end.line,
                    cs: target_tabstop.range.start.character,
                    ce: target_tabstop.range.end.character,
                },
                range: {
                    ls: target_range.start.line,
                    le: target_range.end.line,
                    cs: target_range.start.character,
                    ce: target_range.end.character,
                },
            }
            : null;
    }));
    context.subscriptions.push(coc_nvim_1.commands.registerCommand('coc-exposejump.backward_info', async () => {
        return null;
    }));
}
exports.activate = activate;
// vim: set tabstop=2 softtabstop=2 shiftwidth=2:


/***/ }),
/* 1 */
/***/ ((module) => {

module.exports = require("coc.nvim");;

/***/ })
/******/ 	]);
/************************************************************************/
/******/ 	// The module cache
/******/ 	var __webpack_module_cache__ = {};
/******/ 	
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/ 		// Check if module is in cache
/******/ 		if(__webpack_module_cache__[moduleId]) {
/******/ 			return __webpack_module_cache__[moduleId].exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = __webpack_module_cache__[moduleId] = {
/******/ 			// no module.id needed
/******/ 			// no module.loaded needed
/******/ 			exports: {}
/******/ 		};
/******/ 	
/******/ 		// Execute the module function
/******/ 		__webpack_modules__[moduleId](module, module.exports, __webpack_require__);
/******/ 	
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/ 	
/************************************************************************/
/******/ 	// module exports must be returned from runtime so entry inlining is disabled
/******/ 	// startup
/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(0);
/******/ })()

));