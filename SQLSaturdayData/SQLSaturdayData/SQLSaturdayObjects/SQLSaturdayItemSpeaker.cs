using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SQLSaturdayData
{
	[Serializable()]
	public class SQLSaturdayItemSpeaker
    {
		[System.Xml.Serialization.XmlElement("importID")]
		public string importID { get; set; }

		[System.Xml.Serialization.XmlElement("name")]
		public string name { get; set; }

		[System.Xml.Serialization.XmlElement("label")]
		public string label { get; set; }

		[System.Xml.Serialization.XmlElement("description")]
		public string description { get; set; }

		[System.Xml.Serialization.XmlElement("twitter")]
		public string twitter { get; set; }

		[System.Xml.Serialization.XmlElement("linkedin")]
		public string linkedin { get; set; }

		[System.Xml.Serialization.XmlElement("ContactURL")]
		public string ContactURL { get; set; }

		[System.Xml.Serialization.XmlElement("imageURL")]
		public string imageURL { get; set; }

		[System.Xml.Serialization.XmlElement("imageHeight")]
		public string imageHeight { get; set; }

		[System.Xml.Serialization.XmlElement("imageWidth")]
		public string imageWidth { get; set; }
    }
}
