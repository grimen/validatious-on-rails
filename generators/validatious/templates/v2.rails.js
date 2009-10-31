/**
 *  Helpers for Validatious-On-Rails, mostly related to remote validations.
 */
 
if (typeof v2.rails === 'undefined' || v2.rails === null) {
  v2.rails = {};
  v2.rails.params = {};
  v2.rails.messages = {};
}

/**
* Checks if a string is blank (or undefined).
*/
v2.blank = function blank(value) {
  return v2.empty(value) || /^[\s\t\n]*$/.test(value);
};

/**
* Checks if a string is blank (or undefined).
*/
v2.bool = function bool(value) {
  value += '';
  return value === 'true' || +value > 0;
};

/**
* Checks if a string is null/undefined.
*/
v2.present = function present(value) {
  return !(typeof value === 'undefined' || value === null);
};

/**
* Trim value - fast implementation.
*/
v2.trim = function trim(value) {
  var str = value.replace(/^\s\s*/, ''), ws = /\s/, i = str.length;
  while (ws.test(str.charAt(--i)));
  return str.slice(0, i + 1);
};

/**
* Trim Field elements and their values.
*/
v2.trimField = function trimField(field) {
  for (var i = 0; i < field.__elements.length; i++) {
    field.__elements[i].value = v2.trim(field.__elements[i].value);
  };
};

/**
 *  Generic validator that acts as a client-side validator/helper for remote validator responses.
 */
v2.Validator.add({acceptEmpty: false, fn: function(field, value, params) { return !!params[0]; }, message: null, name: 'remote-client'});

/**
 *  Perform a remote validation on a given field the Validatious way, slightly modified
 */
 v2.rails.performRemoteValidation = function performRemoteValidation(name, field, value, params, message) {
   var field_element = field.__elements[0];
   var url = v2.rails.remoteValidationUrlFor(name, field_element, value, []);

   v2.rails.initializeLastResult(name, field_element.id);

   var xmlHttpRequest = new XMLHttpRequest;
   xmlHttpRequest.open('GET', url, true);
   xmlHttpRequest.onreadystatechange = function() {
     if (this.readyState == XMLHttpRequest.DONE) {
       var validationResult = v2.bool(this.responseText);
       v2.rails.lastRemoteValidationResult[name][field_element.id] = validationResult;

       /* Get all validators for this field, except the current validator. */
       var fieldClasses = v2.trim(field_element.getAttribute('class').replace(new RegExp(name + '\w*'), ''));
       var theOtherValidators = v2.html.validatorsFromString(fieldClasses);

       /* Make remote-client validator trigger validation failure or not. */
       var thisValidator = field_element.id.is('remote-client', validationResult).explain(message);
       v2.html.applyValidators(theOtherValidators, thisValidator);

       /* Trigger validation. */
       thisValidator.item.validate();
     };
   };
   xmlHttpRequest.send(null);
   return v2.rails.lastRemoteValidationResult[name][field_element.id];
 };

/**
 *  Initialize data structure for holding info about last remote AJAX validation result.
 *  We need this to make Validatious play well with remote validations.
 */
 v2.rails.initializeLastResult = function initializeLastResult(validator_name, field_id) {
   if (!v2.present(v2.rails.lastRemoteValidationResult)) {
     v2.rails.lastRemoteValidationResult = new Array();
   };
   if (!v2.present(v2.rails.lastRemoteValidationResult[validator_name])) {
     v2.rails.lastRemoteValidationResult[validator_name] = new Array();
   };
   if (!v2.present(v2.rails.lastRemoteValidationResult[validator_name][field_id])) {
     v2.rails.lastRemoteValidationResult[validator_name][field_id] = false;
   };
 };

/** 
 *  Generate a remote validation poll URL the validatious-on-rails-way,
 *  i.e. auto-detect required params from form builder generated DOM.
 *
 *  Example:
 *    /validates/uniqueness_of?model=article&attribute=title(&id=2)&value=Lorem&params[0]=334&params[1]=hello&...
 */
v2.rails.remoteValidationUrlFor = function remoteValidationUrlFor(name, field, value, params) {
  var modelName = v2.rails.modelNameByField(field);
  var attributeName = v2.rails.attributeNameByField(field);
  var recordId = v2.rails.recordIdByField(field);
  var paramsString = new Array(params.length);
  for (var i = 0; i < params.length; i++) {
    paramsString[i] = 'params[' + i + ']=' + escape(params[i]);
  }
  var url = ['/validates/', name, '?',
              [
                ['model', escape(modelName)].join('='),
                ['attribute', escape(attributeName)].join('='),
                (v2.blank(recordId) ? null : ['id', recordId].join('=')),
                ['value', escape(value)].join('='),
                paramsString.join('&')
              ].join('&')
            ].join('').replace(/\&\&/, '&').replace(/\&$/, '');
  return url;
};

/**
 *  Get form containing a specified field.
 */
v2.rails.formByField = function formByField(field) {
  var parent = field.parentNode;
  while((parent.tagName != 'FORM')) { parent = parent.parentNode; }
  return parent;
};

/**
 *  form_element.id="edit_account_34" => 34
 *  form_element.id="new_account" => nil
 */
v2.rails.recordIdByField = function recordIdByField(field) {
  var form = v2.rails.formByField(field);
  var recordId = form.id.match(/(\d+)$/);
  return (recordId && recordId.length > 1) ? +recordId[1] : null;
};

/**
 *  field_element.name="account[login]" => 'account'
 */
v2.rails.modelNameByField = function modelNameByField(field) {
  var modelName = field.name.match(/^(.*)\[.*\]$/);
  return (modelName.length > 1) ? modelName[1] : '';
};

/**
 * field_element.name="account[login]" => 'login'
 */
v2.rails.attributeNameByField = function attributeNameByField(field) {
  var attributeName = field.name.match(/^.*\[(.*)\]$/);
  return (attributeName.length > 1) ? attributeName[1] : '';
};
