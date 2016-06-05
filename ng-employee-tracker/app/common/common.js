(function () {
    'use strict';

    angular
        .module('employeeApp')
        .factory('common', common);

    common.$inject = ['$http'];

    /* @ngInject */
    function common($http) {
        var service = {
            // common angular dependencies
            $http: $http
            // generic
            // transform object / Json
            ,transform: transform
        };

        return service;

        ////////////////

        function transform(jsonResult, constructor, user, propertyName) {
            if (angular.isArray(jsonResult)) {
                var models = [];
                angular.forEach(jsonResult, function(object) {
                    models.push(transformObject(object, constructor, user, propertyName));
                });
                return models;
            } else {
                return transformObject(jsonResult, constructor, user, propertyName);
            }
        }

        /*** Private Methods ***/
        function transformObject(jsonResult, constructor, user, propertyName) {
            var model = new constructor();
            model.toObject(jsonResult, user, propertyName);
            return model;
        }

    }
})();