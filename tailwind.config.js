/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./index.html", "./src/**/*.bs.js"],
  theme: {
    extend: {
      minHeight: {
        20: "5rem",
        24: "6rem",
        28: "7rem",
      },
    },
  },
  plugins: [],
};
