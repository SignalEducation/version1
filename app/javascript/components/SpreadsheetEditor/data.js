const getData = () => {
  const data = [];

  for (let row = 0; row < 100; row += 1) {
    for (let col = 0; col < 100; col += 1) {
      data.push({
        row,
        col,
        value: '',
        style: '',
      });
    }
  }
  return data;
};

export { getData as default };
