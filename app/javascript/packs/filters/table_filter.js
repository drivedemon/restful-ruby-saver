const moment = require('moment');
const urlParams = new URLSearchParams(window.location.search);
const axios = require('axios');
const token = document.querySelector('[name=csrf-token]').content;
axios.defaults.headers.common['X-CSRF-TOKEN'] = token;

$(document).on('turbolinks:load ready', function () {
  getQueryParams();

  let oldStartDate = moment();
  let oldEndDate = moment();
  $('.location-search-results').hide();
  if (urlParams.get('start_date')) {
    oldStartDate = moment(urlParams.get('start_date')).startOf('hour');
  }

  if (urlParams.get('end_date')) {
    oldEndDate = moment(urlParams.get('end_date')).startOf('hour');
  }

  $('#datepicker').daterangepicker(
    {
      timePicker: true,
      startDate: oldStartDate,
      endDate: oldEndDate,
    },
    function (start, end) {
      const startTime = start.format('YYYY-MM-DDTHH:mm');
      const endTime = end.format('YYYY-MM-DDTHH:mm');
      tableFilter().appendQueryUrl(startTime, endTime);
    }
  );

  $('select.role-filter').on('change', function () {
    tableFilter().appendQueryUrl();
  });

  $('select.report-filter').on('change', function () {
    tableFilter().appendQueryUrl();
  });

  $('#location-results').on('click', function (event) {
    const placeID = event.target.id;
    if (placeID) {
      localStorage.locationName = event.target.name;
      tableFilter().selectLocation(placeID);
    }
  });
});

function getQueryParams() {
  if (urlParams.get('start_date')) {
    const start = urlParams.get('start_date');
    const end = urlParams.get('end_date');
    const reformattedStartDate = moment(start).format('DD/MM/YYYY HH:MM');
    const reformattedEndDate = moment(end).format('DD/MM/YYYY HH:MM');
    $('.datepicker-input').html(`${reformattedStartDate} - ${reformattedEndDate}`);
    $('#datepicker').daterangepicker({
      startDate: start,
      endDate: end,
    });
  }

  if (urlParams.has('role_id')) {
    const roleId = urlParams.get('role_id');
    $('.role-filter').val(roleId);
  }

  if (urlParams.has('reported_from_user')) {
    const reported_from_user = urlParams.get('reported_from_user');
    $('.report-filter').val(reported_from_user);
  }
}

window.tableFilter = () => {
  return {
    dateRange: '',
    name: urlParams.get('name'),
    amount: urlParams.get('amount'),
    location: urlParams.get('location'),
    radius: urlParams.get('radius'),
    level: urlParams.get('level'),
    status: urlParams.get('status'),
    startDate: urlParams.get('start_date'),
    endDate: urlParams.get('end_date'),
    reason: urlParams.get('reason'),
    role: urlParams.get('role'),
    time: urlParams.get('time'),
    orderBy: urlParams.get('order_by') || '',
    order: urlParams.get('order') || '',
    placeID: null,
    locationName:
      !localStorage.locationName || localStorage.locationName === 'undefined'
        ? ''
        : localStorage.locationName,
    // checkbox
    isSelectAll: false,
    selectedDataList: [],
    isSelect: [],
    export_csv_customers_path: 'url',
    clearFilter() {
      localStorage.removeItem('locationName');
      const baseURL = document.location.href.split('?')[0];
      document.location = baseURL;
    },
    orderTable(type) {
      this.order = this.order === 'asc' ? 'desc' : 'asc';
      this.orderBy = type;
      this.appendQueryUrl();
    },
    async searchLocation() {
      $('#location-results').empty();
      $('.location-search-results').hide();
      if (!this.locationName) {
        return;
      }

      const displaySuggestions = (predictions, status) => {
        if (status != google.maps.places.PlacesServiceStatus.OK) {
          const li = $('<li>', {
            class: 'pt-3 pb-0 text-center'
          }).append('No location found');
          $('#location-results').append(li);
          return;
        }

        if (predictions && predictions.length) {
          predictions.map((prediction) => {
            const a = $('<a>', {
              href: 'javascript:void(0)',
              name: `${prediction.description}`,
              id: `${prediction.place_id}`,
            }).append(prediction.description);
            const li = $('<li>').append(a);
            $('#location-results').append(li);
          });
        }
      };

      const service = new google.maps.places.AutocompleteService();
      service.getQueryPredictions({ input: this.locationName }, displaySuggestions);
      $('.location-search-results').show();
    },
    selectLocation(placeID) {
      // Create fake google map to be able to access place detail
      const map = new google.maps.Map(document.getElementById('map'), {
        center: { lat: -33.8666, lng: 151.1958 },
        zoom: 15,
      });

      const request = { placeId: placeID, fields: ['geometry'] };
      const service = new google.maps.places.PlacesService(map);
      service.getDetails(request, (place, status) => {
        if (status == google.maps.places.PlacesServiceStatus.OK) {
          const location = place.geometry.location;
          this.location = `${location.lat()},${location.lng()}`;
          this.appendQueryUrl();
        }
      });
    },
    appendQueryUrl(startDate = '', endDate = '') {
      const roleId = $('.role-filter option:selected').val();
      const reported_from_user = $('.report-filter option:selected').val();
      const urlParams = new URLSearchParams(window.location.search);
      if (startDate && endDate) {
        urlParams.set('start_date', startDate);
        urlParams.set('end_date', endDate);
      } else {
        urlParams.set('start_date', urlParams.get('start_date') || '');
        urlParams.set('end_date', urlParams.get('end_date') || '');
      }

      this.name ? urlParams.set('name', this.name) : urlParams.delete('name');
      this.amount ? urlParams.set('amount', this.amount) : urlParams.delete('amount');
      this.location ? urlParams.set('location', this.location) : urlParams.delete('location');
      this.radius ? urlParams.set('radius', this.radius) : urlParams.delete('radius');
      this.level ? urlParams.set('level', this.level) : urlParams.delete('level');
      this.status ? urlParams.set('status', this.status) : urlParams.delete('status');
      this.time ? urlParams.set('time', this.time) : urlParams.delete('time');
      this.reason ? urlParams.set('reason', this.reason) : urlParams.delete('reason');
      this.orderBy ? urlParams.set('order_by', this.orderBy) : urlParams.delete('order_by');
      this.order ? urlParams.set('order', this.order) : urlParams.delete('order');
      roleId ? urlParams.set('role_id', roleId) : urlParams.delete('role_id');
      reported_from_user ? urlParams.set('reported_from_user', reported_from_user) : urlParams.delete('reported_from_user');

      const baseURL = document.location.href.split('?')[0];
      const url = baseURL + '?' + urlParams;
      document.location = url;
    },
    selectAllCheckbox(tableName) {
      const idList = $(`#${tableName} tr`)
        .toArray()
        .map((t) => +t.id);
      this.isSelectAll = !this.isSelectAll;
      this.selectedDataList = this.isSelectAll ? idList : [];
    },
    selectSingleCheckbox(isSelect, dataID) {
      if (isSelect) {
        this.selectedDataList = [...this.selectedDataList, +dataID];
      } else {
        this.selectedDataList = this.selectedDataList.filter((user) => user !== +dataID);
      }
    },
    isIncluded(userID) {
      return this.selectedDataList.includes(userID);
    },
    clearSelectAll() {
      this.selectedDataList = [];
      this.isSelectAll = false;
    },
    getURLParams() {
      const queryParamsList = {};
      const hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
      if (hashes.length) {
        hashes.map((hash, i) => {
          hash = hashes[i].split('=');
          queryParamsList[hash[0]] = hash[1] ? hash[1].replace('%3A', ':') : hash[1];
        });
      }
      return queryParamsList;
    },
    downloadFile(res) {
      const url = window.URL.createObjectURL(new Blob([res.data]));
      const link = document.createElement('a');
      link.href = url;

      const contentDisposition = res.headers['content-disposition'];
      let fileName = 'unknown';

      if (contentDisposition) {
        const fileNameMatch = contentDisposition.match(/filename="(.+)"/);
        if (fileNameMatch.length === 2) fileName = fileNameMatch[1];
      }

      link.setAttribute('download', fileName);
      document.body.appendChild(link);
      link.click();
      link.remove();
    },
    exportAll(csv_url) {
      const params = this.getURLParams();
      axios.post(csv_url, params).then((res) => {
        this.downloadFile(res);
      });
    },
    exportSelectedList(csv_url) {
      const data = {
        ids: this.selectedDataList,
        ...this.getURLParams(),
      };
      axios.post(csv_url, data).then((res) => {
        this.downloadFile(res);
      });
    },
    exportUserHistory(csv_url, export_type) {
      const data = {
        export_type,
        ...this.getURLParams(),
      };
      axios.post(csv_url, data).then((res) => {
        this.downloadFile(res);
      });
    }
  };
};
