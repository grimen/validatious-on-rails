/**
 *  Helpers for Validatious-On-Rails, mostly related to remote validations.
 */
 
if (typeof v2.Rails === 'undefined' || v2.Rails === null) {
  v2.Rails = {};
}

/**
 *  Generic validator that acts as a client-side validator/helper for remote validator responses.
 */
v2.Validator.add({acceptEmpty: true, fn: function(field, value, params) { return !!params[0]; }, message: null, name: 'remote-client'});

/**
 *  Perform a remote validation on a given field the Validatious way, slightly modified
 */
v2.Rails.performRemoteValidation = function performRemoteValidation(name, field, value, params, message) {
  var field_element = field.__elements[0];
  var url = v2.Rails.remoteValidationUrlFor(name, field_element, value, params);

  var xmlHttpRequest = new XMLHttpRequest;
  xmlHttpRequest.open('GET', url, true);
  xmlHttpRequest.onreadystatechange = function() {
    if (this.readyState == XMLHttpRequest.DONE) {
      var validationResult = (this.responseText == 'true' || this.responseText == '1') ? true : false;
      /* console.log('Validation result: ' + validationResult); */

      /* Get all validators for this field, except the current validator. */
      var fieldClasses = field_element.getAttribute('class').replace(new RegExp(name + '\w*'), '').replace(/^\s+|\s+$/g, '');
      var theOtherValidators = v2.html.validatorsFromString(fieldClasses);

      /* Make remote-client validator trigger validation failure or not. */
      var thisValidator = field_element.id.is('remote-client', validationResult).explain(message);
      v2.html.applyValidators(theOtherValidators, thisValidator);
      thisValidator.item.validate();
    };
  };
  xmlHttpRequest.send(null);
  return true;
};

/** 
 *  Generate a remote validation poll URL the validatious-on-rails-way,
 *  i.e. auto-detect required params from form builder generated DOM.
 *
 *  Example:
 *    /validates/uniqueness_of?model=article&attribute=title(&id=2)&value=Lorem&params[0]=334&params[1]=hello&...
 */
v2.Rails.remoteValidationUrlFor = function remoteValidationUrlFor(name, field, value, params) {
  var modelName = v2.Rails.modelNameByField(field);
  var attributeName = v2.Rails.attributeNameByField(field);
  var recordId = v2.Rails.recordIdByField(field);
  var paramsString = new Array(params.length);
  for (var i = 0; i < params.length; i++) {
    paramsString[i] = 'params[' + i + ']=' + escape(params[i]);
  }
  var url = ['/validates/', name, '?',
              [
                ['model', escape(modelName)].join('='),
                ['attribute', escape(attributeName)].join('='),
                ['id', recordId].join('='),
                ['value', escape(value)].join('='),
                paramsString.join('&')
              ].join('&')
            ].join('').replace(/\&$/, '');
  return url;
};

/**
 *  Get form containing a specified field.
 */
v2.Rails.formByField = function formByField(field) {
  var parent = field.parentNode;
  while((parent.tagName != 'FORM')) { parent = parent.parentNode; }
  return parent;
};

/**
 *  form_element.id="edit_account_34" => 34
 *  form_element.id="new_account" => nil
 */
v2.Rails.recordIdByField = function recordIdByField(field) {
  var form = v2.Rails.formByField(field);
  var recordId = form.id.match(/(\d+)$/);
  return (recordId && recordId.length > 1) ? +recordId[1] : null;
};

/**
 *  field_element.name="account[login]" => 'account'
 */
v2.Rails.modelNameByField = function modelNameByField(field) {
  var modelName = field.name.match(/^(.*)\[.*\]$/);
  return (modelName.length > 1) ? modelName[1] : '';
};

/**
 * field_element.name="account[login]" => 'login'
 */
v2.Rails.attributeNameByField = function attributeNameByField(field) {
  var attributeName = field.name.match(/^.*\[(.*)\]$/);
  return (attributeName.length > 1) ? attributeName[1] : '';
};
