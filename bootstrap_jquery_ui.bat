#!/bin/bash

bin/rails g controller home index
cat << EOS > config/routes.rb
Rails.application.routes.draw do
  root 'home#index'
end
EOS

# install bootstrap
bundle add bootstrap
sed -i -e 's/\# gem \"sassc-rails\"/gem \"sassc-rails\"/' Gemfile
bundle install

cat << EOS >> config/importmap.rb
pin "bootstrap", to: "https://ga.jspm.io/npm:bootstrap@5.3.2/dist/js/bootstrap.esm.js"
pin "@popperjs/core", to: "https://ga.jspm.io/npm:@popperjs/core@2.11.8/lib/index.js"
EOS

echo import \"./bootstrap\" >> app/javascript/application.js
mv app/assets/stylesheets/application.{c,sc}ss
echo @import \"bootstrap\"\; >> app/assets/stylesheets/application.scss

sed -i -e 's/<%= yield %>/<div class="container"><%= yield %><\/div>/' \
  app/views/layouts/application.html.erb

# install jQuery and jQuery-UI
bundle add jquery-rails
bundle add jquery-ui-rails

echo @import \"jquery-ui.css\"\; >> app/assets/stylesheets/application.scss
echo //= require jquery-ui > app/javascript/jquery_ui.js
cat << EOS >> app/javascript/application.js
import "jquery"
import "jquery_ujs"
import "./jquery_ui"
EOS

cat << EOS >> config/importmap.rb
pin "jquery", to: "jquery.min.js", preload: true
pin "jquery_ujs", to: "jquery_ujs.js", preload: true
EOS

echo Rails.application.config.assets.precompile += \%w\( jquery.min.js jquery_ujs.js \) >> config/initializers/assets.rb

cat << EOS > app/views/home/index.html.erb
<div data-controller="home">
  <h1 class="mt-3">This is home page</h1>
  <h6> Pick date using jQuery Datepicker </h6>
  <p>Date: <input type="text" id="datepicker"></p>
  <br>
  <hr>
  <h6> JQuery Draggable Element </h6>
  <div id="draggable" class="ui-widget-content">
    <p>Drag me around</p>
  </div>
  <br>
  <hr>
  <h6> Click Event using JQuery </h6>
  <button id="btn-click" class="btn btn-primary"> Click Me </button>
</div>
EOS

cat << EOS > app/javascript/controllers/home_controller.js
import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="home"
export default class extends Controller {
  connect() {
    console.log("home controller has been connected");
    \$("#datepicker").datepicker();

    var initial_val = 0;
    \$("#btn-click").click(function (e) {
      e.preventDefault();
      var date_value = \$("#datepicker").val();
      alert(\`button has been clicked \${initial_val} and date \${date_value} \`);
      initial_val+= 1;
    });

    \$(function() {
         \$("#draggable").draggable();
      });
  }
}
EOS
