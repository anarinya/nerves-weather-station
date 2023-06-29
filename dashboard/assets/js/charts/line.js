import Chart from "chart.js/auto"

class LineChartBase {
  constructor(ctx, labels, values) {
    this.chart = new Chart(ctx, {
      type: "line",
      data: {
        labels: labels,
        datasets: [{
          label: "Temperature (°F)",
          data: values,
          borderColor: "#4c51bf",
          showLine: true,
          spanGap: true,
          stepSize: 1,
          yAxisId: "y",
          xAxisId: "x",
        }]
      },
      options: {
        layout: {
          padding: {
            left: 50
          }
        },
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
            },
          },
          y: {
            round: true,
            scaleLabel: {
              display: true,
              labelString: "Temperature (°F)"
            },
            ticks: {
              callback: function (value) {
                return value.toFixed(2) + " °F";
              }
            }
          }
        }
      }
    })
  }

  addPoint(label, value) {
    const labels = this.chart.data.labels;
    const data = this.chart.data.datasets[0].data;

    labels.unshift(label);
    data.unshift(value);

    if (data.length > 12) {
      labels.pop();
      data.pop();
    }

    this.chart.update();
  }
}

export default LineChartBase;