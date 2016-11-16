# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
//= require smart_listing
//= require screener

FiltersController = ()->

angular.module("Screener", [])
  .controller("Filters",FiltersController)

`angular.module('Screener').run(["$compile", "$rootScope", "$document", function($compile, $rootScope, $document) {
  return $document.on('page:load', function() {
    var body, compiled;
    body = angular.element('body');
    compiled = $compile(body.html())($rootScope);
    return body.html(compiled);
  });
}]);`