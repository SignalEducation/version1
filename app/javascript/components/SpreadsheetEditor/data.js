const getData = () => {
  const countries = 'US,Germany,UK,Japan,Italy,Greece'.split(',');
  const data = [];

  for (let row = 0; row < 200; row++) {
    data.push([]);
    for (let col = 0; col < 200; col++) {
      data[row].push({
        value: '',
      });
    }
  }
  return data;
};

export { getData as default };
