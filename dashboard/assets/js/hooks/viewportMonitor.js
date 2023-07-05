import { debounce } from "../utils";

// This was used for debugging purposes when figuring out how to get responsive resizing working with charts
// May be useful for something else in the future
const ViewportMonitor = {
  mounted() {
    console.log("viewport monitor mounted");
    window.visualViewport.addEventListener("resize", debounce(this, () => this.handleResize(), 300))
  },
  handleResize() {
    console.log("Viewport size changed to", window.visualViewport.width, "x", window.visualViewport.height)
  },
  destroyed() {
    window.visualViewport.removeEventListener("resize", this.handleResize)
  }
}

export default ViewportMonitor;