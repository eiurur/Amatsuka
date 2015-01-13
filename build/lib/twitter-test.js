(function() {
  var Promise, TLProvider, TwitterCilent, my, settings, _;

  _ = require('lodash');

  Promise = require('es6-promise').Promise;

  my = require('./my').my;

  TLProvider = require('./model').TLProvider;

  TwitterCilent = require('./TwitterClient');

  settings = (process.env.NODE_ENV === "production" ? require('./configs/production') : require('./configs/development')).settings;

  exports.twitterTest = function(user) {
    var twitterClient;
    twitterClient = new TwitterCilent(user);
    return new Promise(function(resolve, reject) {
      return twitterClient.getHomeTimeline().then(function(homeTimeline) {
        console.log('\ngetHomeTimeline homeTimeline -> ', homeTimeline[0]);
        return twitterClient.getListsList();
      }).then(function(lists) {
        var amatsukaList;
        console.log('\ngetListslsit lists -> ', _.pluck(lists, 'name'));
        amatsukaList = _.find(lists, {
          'name': 'Amatsuka'
        });
        console.log('amatsukaList = ', amatsukaList);
        return twitterClient.getListsShow({
          listIdStr: amatsukaList.id_str
        });
      }).then(function(list) {
        console.log('\getListsShow list -> ', list.name);
        return twitterClient.destroyLists({
          listIdStr: list.id_str
        });
      }).then(function(data) {
        console.log('\ndestroyLists data.length -> ', data);
        return twitterClient.createLists({
          name: "Amatsuka",
          mode: 'private'
        });
      }).then(function(list) {
        console.log('\ncreateLists lists -> ', list);
        return twitterClient.createMemberList({
          listIdStr: list.id_str,
          twitterIdStr: '898525572'
        });
      }).then(function(data) {
        console.log('\ncreateMemberList data -> ', data);
        return twitterClient.getListsMembers({
          listIdStr: data.id_str
        });
      }).then(function(members) {
        console.log('\ngetListsCreate members -> ', members);
        return resolve(members);
      })["catch"](function(err) {
        console.log('twitter test err =======> ', err);
        return reject(err);
      });
    });
  };

}).call(this);
