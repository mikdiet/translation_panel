{
  :en => {
    :i18n => {
      :plural => {
        :keys => [:one, :other],
        :rule => lambda { |n| n == 1 ? :one : :other } } } },
  :ru => {
    :i18n => {
      :plural => {
        :keys => [:one, :few, :other],
        :rule => lambda { |n|
          (n % 10) == 1 && (n % 100) !=11 ?
            :one :
            [2, 3, 4].include?(n % 10) && ![12, 13, 14].include?(n % 100) ?
              :few :
              :other } } } }
}
