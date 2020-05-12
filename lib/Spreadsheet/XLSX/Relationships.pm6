use LibXML::Document;
use Spreadsheet::XLSX::Exceptions;

#| A relationships file within an XLSX archive.
class Spreadsheet::XLSX::Relationships {
    #| An individual relationship within an archive.
    class Relationship {
        has Str $.id;
        has Str $.type;
        has Str $.target;
        has Str $.source;
    }

    #| The list of relationships.
    has @.relationships;

    #| Parse the XML content of a relationships file.
    method from-xml(Str $xml) {
        my LibXML::Document $doc .= parse(:string($xml));
        my LibXML::Element $root = $doc.documentElement();
        if $root.nodeName ne 'Relationships' {
            die X::Spreadsheet::XLSX::Format.new: message =>
                    'Relationships file did not start with tag Relationships';
        }
        self.new: relationships => $root.childNodes.map: -> LibXML::Element $entry {
            Relationship.new:
                    :id(self!get-attribute($entry, 'Id')),
                    :type(self!get-attribute($entry, 'Type')),
                    :target(self!get-attribute($entry, 'Target')),
                    :source(self!get-attribute($entry, 'Source', :optional));
        }
    }

    method !get-attribute(LibXML::Element $entry, Str $name, :$optional --> Str) {
        with $entry.getAttributeNode($name) -> LibXML::Attr $attr {
            $attr.string-value
        }
        elsif $optional {
            Nil
        }
        else {
            die X::Spreadsheet::XLSX::Format.new: message =>
                    "Missing attribute '$name' on '$entry.nodeName()'";
        }
    }
}
