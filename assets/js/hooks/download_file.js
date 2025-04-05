const DownloadFile = {
  mounted() {
    this.handleEvent("download-file", ({ filename }) => {
      fetch(`/download/${encodeURIComponent(filename)}`)
        .then(response => response.blob())
        .then(blob => {
          const url = window.URL.createObjectURL(blob);
          const a = document.createElement('a');
          a.href = url;
          a.download = "invoice.pdf";
          document.body.appendChild(a);
          a.click();
          window.URL.revokeObjectURL(url);
          a.remove();
        });
    });
  }
};

export default DownloadFile; 