// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

require('@rails/ujs').start();
require('turbolinks').start();
require('@rails/activestorage').start();
require('channels');
require('moment');
require('alpinejs');

global.toastr = require('toastr');

import '../stylesheets/application';
import './shared/password_match.js';
import './shared/generate_random_password.js';
import './shared/image_upload.js';
import './shared/rating.js';
import './shared/tab_menu.js';
import './bootstrap_custom.js';
import './direct_upload.js';

// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)

// Libs
import './libs/daterangepicker.js';

// Custom
import './image_previewer.js';
import './navbar.js';
import './filters/table_filter.js';

window.jQuery = $;
window.$ = $;