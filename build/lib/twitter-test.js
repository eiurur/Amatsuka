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
        console.log('amatsukaList = ', amatsukaList.id_str);
        return twitterClient.getListsShow({
          listIdStr: amatsukaList.id_str
        });
      }).then(function(list) {
        console.log('\ngetListsShow list.id_str -> ', list.id_str);
        return twitterClient.destroyLists({
          listIdStr: list.id_str
        });
      }).then(function(data) {
        console.log('\ndestroyLists data.id_str -> ', data.id_str);
        return twitterClient.createLists({
          name: "Amatsuka",
          mode: 'private'
        });
      }).then(function(list) {
        console.log('\ncreateLists lists -> ', list.id_str);
        return twitterClient.createListsMembers({
          listIdStr: list.id_str,
          twitterIdStr: '2686409167'
        });
      }).then(function(data) {
        console.log('\ncreateMemberList data -> ', data.id_str);
        return twitterClient.getListsMembers({
          listIdStr: data.id_str
        });
      }).then(function(members) {
        console.log('\ngetListsMembers members.users[0].screen_name -> ', members.users[0].screen_name);
        return resolve(members);
      })["catch"](function(err) {
        console.log('twitter test err =======> ', err);
        return reject(err);
      });
    });
  };

}).call(this);
