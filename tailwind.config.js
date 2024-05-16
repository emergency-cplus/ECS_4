module.exports = {
  content: [
    './app/views/**/*.html.erb',
    './app/helpers/**/*.rb',
    './app/assets/stylesheets/**/*.css',
    './app/javascript/**/*.js'
  ],
  theme: {
    extend: {
      colors: {
        green: {
          500: '#38a169',
          600: '#2f855a',
        },
        blue: {
          500: '#4299e1',
          600: '#3182ce',
        },
      },
    },
  },
  plugins: [
    require('daisyui')
  ],
  daisyui: {
    themes: [
      "cmyk"
    ],
  },
}
