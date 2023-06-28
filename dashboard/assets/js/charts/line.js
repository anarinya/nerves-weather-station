import Chart from "chart.js/auto"

class LineChartBase {
  constructor(ctx, labels, values) {
    this.chart = new Chart(ctx, {
      type: "line",
      data: {
        labels: labels,
        datasets: [{
          label: "Temperature",
          data: values,
          borderColor: "#4c51bf",
          showLine: true,
          spanGap: true,
          stepSize: 1
        }]
      },
      options: {
        animation: {
          duration: 0
        },
        realtime: true,
        elements: {
          line: {
            tension: 0.2
          }
        },
        scales: {
          x: {
            reverse: true,
            ticks: {
              color: "#9e9e9e"
            }
          },
          y: {
            round: true
          }
        }
      }
    })
  }

  addPoint(label, value) {
    const labels = this.chart.data.labels;
    const data = this.chart.data.datasets[0].data;

    labels.push(label);
    data.push(value);

    if (data.length > 12) {
      labels.shift();
      data.shift();
    }

    this.chart.update();
  }
}

export default LineChartBase;