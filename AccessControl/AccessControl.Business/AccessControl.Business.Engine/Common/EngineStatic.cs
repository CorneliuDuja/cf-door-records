#region Usings

using System;
using System.IO;
using System.Runtime.Serialization;
using System.Security.Cryptography;
using System.Text;
using System.Xml;
using System.Xml.Serialization;

#endregion Usings

namespace AccessControl.Business.Engine.Common
{
    public class EngineStatic
    {
        #region Public

        #region Method

        #region Common

        public static string EncryptMd5(string value)
        {
            var stringBuilder = new StringBuilder();
            var md5CryptoServiceProvider = new MD5CryptoServiceProvider();
            var bytes = md5CryptoServiceProvider.ComputeHash(Encoding.UTF8.GetBytes(value ?? string.Empty));
            foreach (var item in bytes)
            {
                stringBuilder.Append(item.ToString("x2").ToLower());
            }
            return stringBuilder.ToString();
        }

        public static T SoapXmlClone<T>(T entity)
        {
            return (T)SoapXmlDeserialize(SoapXmlSerialize(entity), typeof(T));
        }

        public static T XmlClone<T>(T entity)
        {
            return (T)XmlDeserialize(XmlSerialize(entity), typeof(T));
        }

        #endregion Common

        #region Serialization

        public static string SoapXmlSerialize(object value)
        {
            var stringBuilder = new StringBuilder();
            var xmlWriterSettings = new XmlWriterSettings
                                        {
                                            OmitXmlDeclaration = true, 
                                            Indent = true
                                        };
            using (var xmlWriter = XmlWriter.Create(stringBuilder, xmlWriterSettings))
            {
                var type = value.GetType();
                xmlWriter.WriteStartElement(type.FullName);
                var xmlSerializerNamespaces = new XmlSerializerNamespaces();
                xmlSerializerNamespaces.Add(string.Empty, string.Empty);
                var xmlSerializer = new XmlSerializer(new SoapReflectionImporter().ImportTypeMapping(type));
                xmlSerializer.Serialize(xmlWriter, value, xmlSerializerNamespaces);
            }
            return stringBuilder.ToString();
        }

        public static object SoapXmlDeserialize(string value, Type type)
        {
            var xmlTypeMapping = new SoapReflectionImporter().ImportTypeMapping(type);
            var xmlSerializer = new XmlSerializer(xmlTypeMapping);
            var xmlDocument = new XmlDocument();
            xmlDocument.LoadXml(value);
            var xmlTextReader = new XmlTextReader(new StringReader(xmlDocument.OuterXml));
            xmlTextReader.ReadStartElement(type.FullName);
            return xmlSerializer.Deserialize(xmlTextReader);
        }

        public static T SoapXmlDeserialize<T>(string value)
        {
            return (T)SoapXmlDeserialize(value, typeof(T));
        }

        public static string PortableXmlSerialize(object value)
        {
            var memoryStream = new MemoryStream();
            byte[] bytes;
            using (var customXmlTextWriter = new CustomXmlTextWriter(memoryStream, null) {Formatting = Formatting.Indented})
            {
                var dataContractSerializer = new DataContractSerializer(value.GetType());
                dataContractSerializer.WriteObject(customXmlTextWriter, value);
                customXmlTextWriter.Flush();
                memoryStream.Seek(0, SeekOrigin.Begin);
                bytes = new byte[memoryStream.Length];
                memoryStream.Read(bytes, 0, (int)memoryStream.Length);
            }
            memoryStream.Dispose();
            return Encoding.UTF8.GetString(bytes);
        }

        public static string XmlSerialize(object value)
        {
            var stringBuilder = new StringBuilder();
            var xmlWriterSettings = new XmlWriterSettings
                                        {
                                            OmitXmlDeclaration = true, 
                                            Indent = true
                                        };
            using (var xmlWriter = XmlWriter.Create(stringBuilder, xmlWriterSettings))
            {
                var xmlSerializerNamespaces = new XmlSerializerNamespaces();
                xmlSerializerNamespaces.Add(string.Empty, string.Empty);
                var xmlSerializer = new XmlSerializer(value.GetType());
                xmlSerializer.Serialize(xmlWriter, value, xmlSerializerNamespaces);
            }
            return stringBuilder.ToString();
        }

        public static object XmlDeserialize(string value, Type type)
        {
            var xmlSerializer = new XmlSerializer(type);
            var xmlDocument = new XmlDocument();
            xmlDocument.LoadXml(value);
            return xmlSerializer.Deserialize(new XmlTextReader(new StringReader(xmlDocument.OuterXml)));
        }

        public static T XmlDeserialize<T>(string value)
        {
            return (T)XmlDeserialize(value, typeof(T));
        }

        #endregion Serialization

        #endregion Method

        #endregion Public
    }
}