import Vue from 'vue'
import BootstrapVue from 'bootstrap-vue'

import index from './components/index/index'

Vue.use(BootstrapVue)
/* eslint-disable no-new */
new Vue({
  el: '#app',
  template: '<App/>',
  components: { index }
})

// console.log(vm)
