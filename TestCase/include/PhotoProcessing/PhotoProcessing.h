#ifndef PHOTOPROCESSING_H
#define PHOTOPROCESSING_H

#include <cmath>

#include <QImage>
#include <QObject>
#include <QRandomGenerator>
#include <QStringBuilder>
#include <QTemporaryDir>
#include <QtConcurrent>

///
/// \brief The PhotoProcessing class - Класс служит для простой обработки изображений и отправки данных в qml.
///
class PhotoProcessing : public QObject {
    Q_OBJECT

#define blurMatrixLength 9

public:
    explicit PhotoProcessing(QObject* parent = nullptr);

    ///
    /// \brief setUpNewImage - Функция сохранять новое изображение в tmp папке и устанавливает новое изображение в UI.
    /// \param image - Новое изображение.
    /// \param imagePath - Путь к новому изображению.
    ///
    void setUpNewImage(const QImage& image, const QString& imagePath);

public slots:
    ///
    /// \brief processBoxBlur - Функция обрабатывает блюрит изображение с помощью BoxBlur.
    /// \param imagePath - Путь к изображению.
    ///
    void processBoxBlur(QString imagePath, const int samples);

    ///
    /// \brief procesRgbToGray - Функция переводит изображение в grayScale.
    /// \param imagePath - Путь к изображению.
    ///
    void procesRgbToGray(QString imagePath);

    ///
    /// \brief processHue - Устанавливает новый тон изображению.
    /// \param imagePath - Путь к изображению.
    /// \param hue - Ноывй тон изображения.
    ///
    void processHue(QString imagePath, const quint8 hue);

    ///
    /// \brief processContrast - Функция изменяет контраст изображение.
    /// \param tmpImagePath - Путь к изображению, которое будет изменено.
    /// \param savePath - Путь по которому будет сохранено изменное изображение
    /// \param contrast - Параметр контрастности, на которое будет увеличена сама яркость. От -127 до 127.
    ///
    void processContrast(QString tmpImagePath, const QString &savePath, const qint8 contrast);

    ///
    /// \brief processBrightness - Функция изменяет яркость изображение.
    /// \param tmpImagePath - Путь к изображению, которое будет изменено.
    /// \param savePath - Путь по которому будет сохранено изменное изображение.
    /// \param brightness - Параметр яркости, на которое будет увеличена сама яркость. От 0.0 до 2.0.
    ///
    void processBrightness(QString tmpImagePath, const QString &savePath, const float brightness);

    ///
    /// \brief processRotate - Функция делает разворот изображения на 90 градусов.
    /// \param imagePath - Путь к изображению.
    ///
    void processRotate(QString imagePath);

    ///
    /// \brief saveFile - Функция сохраняет файл по новому пути.
    /// \param imagePath - Старый путь файла.
    /// \param newImagePath - Новый путь файла
    /// \return
    ///
    inline bool saveFile(QString imagePath, QString newImagePath)
    {
        /* Если файл уже существует */
        if (QFile::exists(newImagePath.remove("file://"))) {
            QFile::remove(newImagePath);
        }

        return QFile::copy(imagePath.remove("file://"), newImagePath);
    }

    ///
    /// \brief createTempImage - Функция копирует изображение во временную папку, для операций над ним.
    /// \param imagePath - Путь к изображению.
    /// \return Путь к временному изображению.
    ///
    inline QString createTempImage(QString imagePath)
    {
        QFileInfo imageInfo(imagePath.remove("file://"));

        const QString newFileName = temporaryDir.path() % "/" % QString::number(QRandomGenerator::global()->bounded(100000, 999999)) % imageInfo.fileName();

        if (QFile::copy(imagePath, newFileName)) {
            return newFileName;
        }

        return "";
    }

signals:
    ///
    /// \brief imageEditChanged - Сигнал передается в qml с целью изменить изображение на новое.
    /// \param newImagePath - Путь к новому изображению
    ///
    void imageEditChanged(const QString& newImagePath);

    ///
    /// \brief loadingStartedChanged - Сигнал передается в qml и запускает экран загрузки, блокирую остальные элементы, которые влияют на класс PhotoProcessing.
    ///
    void loadingStartedChanged();

private:
    ///
    /// \brief truncate - Функция обрабатывает максимальное значение RGB.
    /// \param value - Значение RGB.
    /// \return Если значение превышает максимальное значение одного из цветов, то функция вернет '255', если же значение меньше, то '0'.
    ///
    size_t truncatePixelValue(const size_t value)
    {
        if (value == 0) {
            return 0;
        } else if (value > 255) {
            return 255;
        }

        return value;
    }

    QTemporaryDir temporaryDir;
};

#endif // PHOTOPROCESSING_H
