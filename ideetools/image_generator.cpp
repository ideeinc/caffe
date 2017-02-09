#include <QtCore/QtCore>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <random>
#include <cmath>
using namespace cv;

const int OUTPUT_WIDTH  = 224;
const int OUTPUT_HEIGHT = 224;
const float ROTATION_RANGE = 180.0; // 回転±
const float ZOOM_RANGE = 0.2; // ズーム幅(縮小はしない、回転すると黒の余白が増えるため)
const int MULTIPLE = 28;


class Image {
    Mat mat;

public:
    Image() {}

    Image(const QString &path)
    {
        if (!QFileInfo(path).exists()) {
            qCritical() << "no such file:" << path;
            return;
        }
        mat = cv::imread(qPrintable(path), 1);
    }

    Image(const Image &other) { mat = other.mat.clone(); }

    Image &operator=(const Image &other)
    {
        mat = other.mat.clone();
        return *this;
    }

    ~Image() {}

    int width() const { return mat.cols; }
    int height() const { return mat.rows; }
    bool isEmpty() const { return mat.empty(); }

    // 明度の正規化
    void normalize()
    {
        if (mat.empty()) {
            qCritical() << "normalize error: empty image";
            return;
        }

        Mat dst;
        double min, max;
        cv::minMaxLoc(mat, &min, &max);
        if ((int)min != 0 || (int)max != 255) {
            cv::convertScaleAbs(mat, dst, 255.0/(max-min), -255.0*min/(max-min));
            mat.release();
            mat = dst; // shallow copy
        }
    }

    // 回転 (拡大縮小も可)
    void rotate(float angle, float scale=1.0)
    {
        if (mat.empty()) {
            qCritical() << "rotate error: empty image";
            return;
        }

        if (scale < 1.0) {
            // zoom out
            Mat dst = Mat::ones(height(), width(), CV_8UC3);  // 元のサイズ
            int w = mat.cols * scale;
            int h = mat.rows * scale;
            int x = (width()-w)/2;
            int y = (height()-h)/2;
            resize(w, h);

            cv::Rect rect(x,y,w,h);
            cv::Mat submat = dst(rect);
            mat.copyTo(submat);  // 貼り付け
            mat.release();
            mat = dst;
            return rotate(angle, 1.0);
        }

        Mat dst;
        Point2f center(mat.cols/2.0, mat.rows/2.0); // 画像の中心
        Mat matrix = cv::getRotationMatrix2D(center, angle, scale);
        warpAffine(mat, dst, matrix, mat.size(), cv::INTER_CUBIC);
        mat.release();
        mat = dst; // shallow copy
    }

    // リサイズ
    void resize(int width, int height)
    {
        if (mat.empty()) {
            qCritical() << "resize error: empty image";
            return;
        }

        if (width == mat.cols && height == mat.rows) {
            return;
        }

        // 出力画像
        Mat dst = Mat::ones(height, width, CV_8U);
        if (width < mat.cols || height < mat.rows) {
            // 縮小
            cv::resize(mat, dst, dst.size(), 0.5, 0.5, cv::INTER_AREA);
        } else {
            // 拡大
            cv::resize(mat, dst, dst.size(), cv::INTER_CUBIC);
        }
        mat.release();
        mat = dst; // shallow copy
    }

    // 保存
    bool save(const QString &path) const
    {
       if (mat.empty()) {
            qCritical() << "save error: empty image";
            return false;
        }

        std::vector<int> params(2);
        params[0] = CV_IMWRITE_JPEG_QUALITY; // JPEG品質
        params[1] = 95;
        return imwrite(qPrintable(path), mat, params);
    }

    void show(const QString &title)
    {
        if (mat.empty()) {
            qCritical() << "show error: empty image";
            return;
        }
        cv::namedWindow(qPrintable(title), cv::WINDOW_AUTOSIZE);
        cv::imshow(qPrintable(title), mat);
    }
};


class ImageGenerator {
    float rotationRange  {0};
    float zoomRange  {0};

public:
    ImageGenerator(float rotate = ROTATION_RANGE, float zoom = ZOOM_RANGE)
        : rotationRange(rotate), zoomRange(zoom) {}

    static uint rand(uint min, uint max)
    {
        static std::random_device randev;
        static std::mt19937 mt(randev());
        static QMutex mutex;

        mutex.lock();
        std::uniform_int_distribution<uint> uniform(min, max);
        uint ret = uniform(mt);
        mutex.unlock();
        return ret;
    }

    static float randf(float min, float max)
    {
        float num = rand(0, UINT_MAX)/(float)UINT_MAX;  // 0.0 - 1.0
        float ret = std::abs(max-min) * num + qMin(max, min);
        return ret;
    }

    // 生成
    void generate(const QString &srcDirPath, const QString &dstDirPath, int multiple) const
    {
        if (QFileInfo(srcDirPath).absolutePath() == QFileInfo(dstDirPath).absolutePath()) {
            qDebug() << "change dst directory";
            return;
        }

        QDir dstDir(dstDirPath);
        if (!dstDir.exists()) {
            dstDir.mkpath(".");
        }
        QDir srcDir(srcDirPath);

        const QStringList filter = { "*.jpg", "*.jpeg" };
        for (auto &f : srcDir.entryInfoList(filter, QDir::Files | QDir::QDir::Readable)) {
            auto jpg = f.absoluteFilePath();
            Image origImg(qPrintable(jpg));
            origImg.normalize();

            for (int i = 0; i < multiple; i++) {
                Image img(origImg);
                img.resize(OUTPUT_WIDTH, OUTPUT_HEIGHT); // resize

                if (i > 0) {
                    // zoom and rotate
                    float deg = randf(-rotationRange, rotationRange);
                    float zoom = randf(0, zoomRange);
                    zoom = (zoom >= 0.0) ? 1.0+zoom : 1.0/(1.0+std::abs(zoom));
                    qDebug() << "deg:" << deg << "zoom:" << zoom;
                    img.rotate(deg, zoom);
                }

                QString dstName = f.completeBaseName() + "_" + QString::number(i) + "." + f.suffix();
                img.save(dstDir.absoluteFilePath(dstName));
            }
        }
    }
};


int main(int argc, const char *argv[])
{
    switch (argc) {
    case 2: {
        Image image(argv[1]);
        image.normalize();
        image.resize(OUTPUT_WIDTH, OUTPUT_HEIGHT);
        image.show("RESIZE");
        cv::waitKey(0);
        break; }

    case 3:
        ImageGenerator().generate(argv[1], argv[2], MULTIPLE);
        break;

    default:
        qDebug() << "bad arguments";
        return 1;
    }
    return 0;
}

// CompileOptions: -m64 -O2 -fPIC -pipe -std=c++0x -D_REENTRANT -DQT_NO_DEBUG -DQT_CORE_LIB -isystem /usr/include/x86_64-linux-gnu/qt5 -I. -Wl,-O2 -lopencv_core -lopencv_highgui -lopencv_imgproc -lQt5Core
// command: cpi /path/to/this_file /path/to/jpeg_file
