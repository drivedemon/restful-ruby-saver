# db/seeds/helpstatus.rb
HelpeeRequestStatus.create(
  [
    { name: 'Pending' },
    { name: 'Confirm' },
    { name: 'Complete' },
    { name: 'Reject' },
    { name: 'Cancel' }
  ]
)

HelperRequestStatus.create(
  [
    { name: 'Pending' },
    { name: 'Confirm' },
    { name: 'Complete' },
    { name: 'Reject' },
    { name: 'Cancel' }
  ]
)
