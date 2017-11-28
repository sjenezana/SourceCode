namespace EBookAnalyzer
{
    partial class Form1
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.txtShow = new System.Windows.Forms.RichTextBox();
            this.btndownload = new System.Windows.Forms.Button();
            this.btnstatus = new System.Windows.Forms.Button();
            this.SuspendLayout();
            // 
            // txtShow
            // 
            this.txtShow.Location = new System.Drawing.Point(29, 12);
            this.txtShow.Name = "txtShow";
            this.txtShow.Size = new System.Drawing.Size(308, 179);
            this.txtShow.TabIndex = 1;
            this.txtShow.Text = "";
            // 
            // btndownload
            // 
            this.btndownload.Location = new System.Drawing.Point(12, 235);
            this.btndownload.Name = "btndownload";
            this.btndownload.Size = new System.Drawing.Size(75, 23);
            this.btndownload.TabIndex = 2;
            this.btndownload.Text = "download";
            this.btndownload.UseVisualStyleBackColor = true;
            // 
            // btnstatus
            // 
            this.btnstatus.Location = new System.Drawing.Point(117, 235);
            this.btnstatus.Name = "btnstatus";
            this.btnstatus.Size = new System.Drawing.Size(75, 23);
            this.btnstatus.TabIndex = 3;
            this.btnstatus.Text = "status";
            this.btnstatus.UseVisualStyleBackColor = true;
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(659, 370);
            this.Controls.Add(this.btnstatus);
            this.Controls.Add(this.btndownload);
            this.Controls.Add(this.txtShow);
            this.Name = "Form1";
            this.Text = "Form1";
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.RichTextBox txtShow;
        private System.Windows.Forms.Button btndownload;
        private System.Windows.Forms.Button btnstatus;
    }
}

