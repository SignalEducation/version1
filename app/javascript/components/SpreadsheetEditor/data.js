const getData = () => {
  const data = [];

  for (let row = 0; row < 10; row += 1) {
    for (let col = 0; col < 10; col += 1) {
      data.push({
        row,
        col,
        value: "",
        style: "",
        format: "",
        fontSizeIdx: 5,
      });
    }
  }
  return data;
};

export { getData as default };
