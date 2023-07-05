import Chart from "chart.js/auto"

const getGradient = (ctx, chartArea) => {
  let width, height, gradient;

  const chartWidth = chartArea.right - chartArea.left;
  const chartHeight = chartArea.bottom - chartArea.top;

  if (!gradient || width !== chartWidth || height !== chartHeight) {
    // Create gradient size for first render or size when chart changes
    width = chartWidth;
    height = chartHeight;

    gradient = ctx.createLinearGradient(0, chartArea.bottom, 0, chartArea.top);
    gradient.addColorStop(0, "rgb(6, 182, 212)");
    gradient.addColorStop(1, " rgb(219, 39, 119)");
  }
  return gradient;
}

class LineChartBase {
  constructor(ctx, labels, values) {
    this.chart = new Chart(ctx, {
      type: "line",
      data: {
        labels: labels,
        datasets: [{
          label: "Temperature (°F)",
          data: values,
          showLine: true,
          spanGap: true,
          yAxisId: "y",
          xAxisId: "x",
          borderColor: function (context) {
            const chart = context.chart;
            const { ctx, chartArea } = chart;

            // This happens on initial load
            if (!chartArea) return null;
            return getGradient(ctx, chartArea);
          },
        }]
      },
      options: {
        responsive: true,
        interaction: {
          intersect: false,
          axis: 'x'
        },
        maintainAspectRatio: false,
        resizeDelay: 200,
        layout: {
          padding: {
            left: 40
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
              color: "#9e9e9e",
              count: 5,
              stepSize: 20
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
                return value.toFixed(1) + " °F";
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