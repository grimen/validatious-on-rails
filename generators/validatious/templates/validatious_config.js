// -------------------------------------------
//  VALIDATIOUS 2.0: Configuration
// -------------------------------------------
//
// More: http://validatious.org/learn/references
//

// Auto-validate form with this class.
// 
// v2.Form.autoValidateClass = 'validate';

// Trigger validation on action with this class.
// 
v2.Form.actionButtonClass = 'commit';  // Formtastic: Use 'commit'

// Validate any/all of the validations in a block with this class.
// 
// Example:
// 
//  <div class="validate_any">
//    ...
//  </div>
// 
// v2.html.validateAnyClass = 'validate_any';
// v2.html.validateAnyClass = 'validate_all';

// Make generated validation classes namespaced to avoid clashes with other classes.
// 
// v2.Validator.prefix = 'v2_';

// Validate instantly or on submit.
// 
v2.Field.prototype.instant = true;
v2.Field.prototype.instantWhenValidated = true;

// Validate all hidden fields.
// 
// v2.Field.prototype.validateHidden = false;

// Jump to first invalid field on error.
// 
v2.Form.prototype.scrollToFirstWhenFail = true;

// Maximum number of errors at the same time.
// 
//  * -1, default value, display all messages
//  * 0, display no messages, only append class names on failing elements
//  * n, where n is any positive integer, display no more than this many messages
// 
// v2.Field.prototype.displayErrors = 1;

// Position of errors.
// 
v2.Field.prototype.positionErrorsAbove = false;
v2.Fieldset.prototype.positionErrorsAbove = false;

// Error classes.
//
// Example:
//
// <fieldset
//   <div class="field error"
//     <label for="name">Name</label
//     <input type="text" name="name" id="name" class="required word"
//     <ul class="errors"
//       <li>Name is required</li
//     </ul
//   </div
//   <div class="field error"
//     <label for="email">E-mail</label
//     <input type="text" name="email" id="email" class="email" value="name@"
//     <ul class="errors"
//       <li>E-mail should be a valid email address</li
//     </ul
//   </div
// </fieldset>
// 
v2.Fieldset.prototype.messagesClass = 'errors';   // Formtastic: Use 'errors'
v2.Fieldset.prototype.failureClass = 'error';     // Formtastic: Use 'error'
v2.Fieldset.prototype.successClass = '';
v2.Field.prototype.messagesClass = 'errors';      // Formtastic: Use 'errors'
v2.Field.prototype.failureClass = 'error';        // Formtastic: Use 'error'
v2.Field.prototype.successClass = '';
