import LineChartBase from "../charts/line";

const LineChart = {
  mounted() {
    const { labels, values } = JSON.parse(this.el.dataset.chartData);
    this.chart = new LineChartBase(this.el, labels, values);

    this.handleEvent("new-point", ({ label, value }) => {
      this.chart.addPoint(label, value);
    })
  }


}

export default LineChart;