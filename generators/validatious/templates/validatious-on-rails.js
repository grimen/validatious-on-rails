//
// Helpers for remote validations.
//

// Perform a remote validation on a given field the Validatious way, slightly modified
///
function performRemoteValidation(name, field, value, params) {
  var field_element = field.__elements[0];
  var url = remoteValidationUrlFor(name, field_element, value, params);
  
  var xmlHttpRequest = new XMLHttpRequest;
  xmlHttpRequest.open('GET', url, true);
  xmlHttpRequest.onreadystatechange = function() {
    if (this.readyState == XMLHttpRequest.DONE) {
      var validationResult = this.responseText;
      // Trigger a failing client-side uniqueness validation.
      // console.log('Validation result:' + validationResult);
    };
  };
  xmlHttpRequest.send(null);
  return true;
}

// Generate a remote validation poll URL the validatious-on-rails-way,
// i.e. auto-detect required params from form builder generated DOM.
//
// Example:
//  /validates/uniqueness_of?model=article&attribute=title(&id=2)&value=Lorem&params[0]=334&params[1]=hello&...
//
function remoteValidationUrlFor(name, field, value, params) {
  var modelName = modelNameByField(field);
  var attributeName = attributeNameByField(field);
  var recordId = recordIdByField(field);
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

// Get form containing a specified field.
//
function formByField(field) {
  var parent = field.parentNode;
  while((parent.tagName != 'FORM')) { parent = parent.parentNode; }
  return parent;
};

// form_element.id="edit_account_34" => 34
// form_element.id="new_account" => nil
//
function recordIdByField(field) {
  var form = formByField(field);
  var recordId = form.id.match(/(\d+)$/);
  return (recordId && recordId.length > 1) ? +recordId[1] : null;
};

// field_element.name="account[login]" => 'account'
//
function modelNameByField(field) {
  var modelName = field.name.match(/^(.*)\[.*\]$/);
  return (modelName.length > 1) ? modelName[1] : '';
};

// field_element.name="account[login]" => 'login'
//
function attributeNameByField(field) {
  var attributeName = field.name.match(/^.*\[(.*)\]$/);
  return (attributeName.length > 1) ? attributeName[1] : '';
};
